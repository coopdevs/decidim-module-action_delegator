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

      it "sends an export mail" do
        expect(Decidim::ExportMailer)
          .to receive(:export)
          .with(user, I18n.t("decidim.admin.consultations.results.export_filename"), kind_of(Decidim::Exporters::ExportData))
          .and_return(mailer)

        subject.perform_now(user, consultation)
      end

      context "when the consultation is active" do
        let!(:consultation) { create(:consultation, :active, organization: organization) }

        it "does not export anything" do
          expect(Decidim::ExportMailer).to receive(:export) do |_user, _name, export_data|
            expect(export_data.read).to eq("\n")
          end.and_return(mailer)

          subject.perform_now(user, consultation)
        end
      end

      context "when the consultation is finished" do
        context "and the results are published" do
          let!(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }

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

            subject.perform_now(user, consultation)
          end
        end
      end
    end
  end
end
