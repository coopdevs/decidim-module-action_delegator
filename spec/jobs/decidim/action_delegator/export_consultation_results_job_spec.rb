# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe ExportConsultationResultsJob do
    subject { described_class }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization: organization) }

    let!(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }
    let!(:question) { create(:question, consultation: consultation, title: { "ca" => "question_title" }) }
    let!(:response) { create(:response, question: question, title: { "ca" => "A" }) }
    let!(:other_response) { create(:response, question: question, title: { "ca" => "B" }) }

    let!(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:another_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:yet_another_user) { create(:user, :admin, :confirmed, organization: organization) }

    let(:votes) { consultation.questions.first.total_votes }

    before do
      question.votes.create(author: user, response: response)
      question.votes.create(author: other_user, response: response)
      question.votes.create(author: another_user, response: response)
      question.votes.create(author: yet_another_user, response: other_response)

      create(:authorization, :direct_verification, user: user, metadata: { membership_type: "producer", membership_weight: 2 })
      create(:authorization, :direct_verification, user: other_user, metadata: { membership_type: "consumer", membership_weight: 3 })
      create(:authorization, :direct_verification, user: another_user, metadata: { membership_type: "consumer", membership_weight: 1 })

      create(:authorization, :direct_verification, user: yet_another_user, metadata: { membership_type: "consumer", membership_weight: 1 })
    end

    describe "queue" do
      it "is queued to default" do
        expect(subject.queue_name).to eq "default"
      end
    end

    describe "#perform" do
      let(:mailer) { double(:mailer, deliver_now: true) }
      let(:exporter_class) { class_double(Decidim::Exporters::CSV) }
      let(:exporter) { instance_double(Decidim::Exporters::CSV, export: export_data) }

      context "when passing type_and_weight" do
        let(:export_data) do
          double(
            :export_data,
            read: "question;response;membership_type;membership_weight;votes_count\nquestion_title;A;consumer;3;1\nquestion_title;A;consumer;1;1\nquestion_title;A;producer;2;1\nquestion_title;B;consumer;1;1\n"
          )
        end

        it "fetches data calling TypeAndWeight" do
          type_and_weight = instance_double(TypeAndWeight)
          expect(TypeAndWeight)
            .to receive(:new).with(consultation).and_return(type_and_weight)
          expect(type_and_weight).to receive(:query).and_return([])

          subject.perform_now(user, consultation, :type_and_weight)
        end

        it "sends an export mail from the collection data" do
          allow(exporter_class).to receive(:new)
            .with(kind_of(ActiveRecord::Relation), ConsultationResultsSerializer)
            .and_return(exporter)
          allow(Decidim::Exporters).to receive(:find_exporter)
            .with("CSV").and_return(exporter_class)

          expect(Decidim::ExportMailer)
            .to receive(:export)
            .with(
              user,
              I18n.t("decidim.admin.consultations.results.export_filename"),
              export_data
            )
            .and_return(mailer)

            subject.perform_now(user, consultation, :type_and_weight)
        end

        context "when the consultation is active" do
          let!(:consultation) { create(:consultation, :active, organization: organization) }
          let(:export_data) { double(:export_data, read: "\n") }

          it "does not export anything" do
            expect(Decidim::ExportMailer).to receive(:export) do |_user, _name, export_data|
              expect(export_data.read).to eq("\n")
            end.and_return(mailer)

            subject.perform_now(user, consultation, :type_and_weight)
          end
        end

        context "when the consultation is finished" do
          context "and the results are published" do
            let!(:consultation) do
              create(:consultation, :finished, :published_results, organization: organization)
            end

            it "exports consultation's by membership" do
              expect(Decidim::ExportMailer).to receive(:export) do |_user, _name, export_data|
                expect(export_data.read).to eq(<<-CSV.strip_heredoc)
                question;response;membership_type;membership_weight;votes_count
                question_title;A;consumer;3;1
                question_title;A;consumer;1;1
                question_title;A;producer;2;1
                question_title;B;consumer;1;1
                CSV
              end.and_return(mailer)

              subject.perform_now(user, consultation, :type_and_weight)
            end
          end
        end
      end

      context "when passing sum_of_weights" do
        let(:export_data) { double(:export_data, read: "data\n") }

        it "fetches data calling SumOfWeights" do
          sum_of_weights = instance_double(SumOfWeights)
          expect(SumOfWeights)
            .to receive(:new).with(consultation).and_return(sum_of_weights)
          expect(sum_of_weights).to receive(:query).and_return([])

          subject.perform_now(user, consultation, :sum_of_weights)
        end

        it "sends an export mail with the collection data" do
          allow(exporter_class).to receive(:new)
            .with(kind_of(ActiveRecord::Relation), SumOfWeightsSerializer)
            .and_return(exporter)
          allow(Decidim::Exporters).to receive(:find_exporter)
            .with("CSV").and_return(exporter_class)

          expect(Decidim::ExportMailer)
            .to receive(:export)
            .with(
              user,
              I18n.t("decidim.admin.consultations.results.export_filename"),
              export_data
            )
            .and_return(mailer)

            subject.perform_now(user, consultation, :sum_of_weights)
        end

        context "when the consultation is active" do
          let!(:consultation) { create(:consultation, :active, organization: organization) }

          it "does not export anything" do
            expect(Decidim::ExportMailer).to receive(:export) do |_user, _name, export_data|
              expect(export_data.read).to eq("\n")
            end.and_return(mailer)

            subject.perform_now(user, consultation, :sum_of_weights)
          end
        end

        context "when the consultation is finished" do
          let!(:consultation) do
            create(:consultation, :finished, :published_results, organization: organization)
          end

          it "exports consultation's by membership" do
            expect(Decidim::ExportMailer).to receive(:export) do |_user, _name, export_data|
              expect(export_data.read).to eq(<<-CSV.strip_heredoc)
                question;response;votes_count
                question_title;A;6
                question_title;B;1
              CSV
            end.and_return(mailer)

            subject.perform_now(user, consultation, :sum_of_weights)
          end
        end
      end
    end
  end
end
