# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe PublishedResponses do
    subject { described_class.new(consultation) }

    let(:organization) { create(:organization) }

    let!(:question) { create(:question, consultation: consultation) }
    let!(:response) { create(:response, question: question, title: { "en" => "A" }) }

    let!(:other_consultation) { create(:consultation, :finished, :published_results, organization: organization) }
    let!(:other_question) { create(:question, consultation: other_consultation) }
    let!(:other_response) { create(:response, question: other_question, title: { "en" => "other" }) }

    describe "#query" do
      context "when the consultation is active" do
        let(:consultation) { create(:consultation, :active, organization: organization) }

        it "returns empty" do
          expect(subject.query).to be_empty
        end
      end

      context "when the consultation is finished" do
        context "and the questions are published" do
          let!(:question) { create(:question, :published, consultation: consultation) }

          context "and the results are published" do
            let(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }

            it "returns the responses to its questions" do
              expect(subject.query).to match_array([response])
            end
          end

          context "and the results are not published" do
            let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }

            it "returns empty" do
              expect(subject.query).to be_empty
            end
          end
        end

        context "and the questions are not published" do
          let(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }
          let!(:question) { create(:question, :unpublished, consultation: consultation) }

          it "returns empty" do
            expect(subject.query).to be_empty
          end
        end
      end
    end
  end
end
