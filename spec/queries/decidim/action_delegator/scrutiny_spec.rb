# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Scrutiny do
      subject { described_class.new(consultation) }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, organization: organization) }
      let(:user) { create(:user, :confirmed, organization: organization) }
      let(:other_user) { create(:user, :confirmed, organization: organization) }

      describe "#questions" do
        let(:question) { create(:question, :published, consultation: consultation) }
        let(:response) { create(:response, question: question) }

        let!(:unvoted_question) { create(:question, :published, consultation: consultation) }
        let!(:unpublished_question) { create(:question, :unpublished, consultation: consultation) }

        before do
          question.votes.create(author: user, response: response)
          question.votes.create(author: other_user, response: response)
        end

        it "returns the consultation's published questions" do
          expect(subject.questions.map(&:id)).to contain_exactly(question.id, unvoted_question.id)
        end

        it "returns each question's stats" do
          cache = subject.send(:build_questions_cache)

          expect(cache[question.id].total_delegates).to eq(1)
          expect(cache[question.id].total_participants).to eq(3)

          expect(cache[unvoted_question.id].total_delegates).to eq(0)
          expect(cache[unvoted_question.id].total_participants).to eq(0)
        end
      end
    end
  end
end
