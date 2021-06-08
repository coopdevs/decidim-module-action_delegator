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

        let(:granter) { create(:user, organization: organization) }
        let(:setting) { create(:setting, consultation: consultation) }

        before do
          question.votes.create(author: user, response: response)
          question.votes.create(author: other_user, response: response)

          create(:delegation, granter_id: granter.id, grantee_id: user.id, setting: setting)
          question.votes.create(author: granter, response: response)
        end

        it "returns the consultation's published questions" do
          expect(subject.questions.map(&:id)).to contain_exactly(question.id, unvoted_question.id)
        end

        it "returns each question's stats" do
          questions = subject.questions

          expect(questions.first.id).to eq(unvoted_question.id)
          expect(questions.first.total_delegates).to eq(0)
          expect(questions.first.total_participants).to eq(0)

          expect(questions.second.id).to eq(question.id)
          expect(questions.second.total_delegates).to eq(1)
          expect(questions.second.total_participants).to eq(3)
        end
      end
    end
  end
end
