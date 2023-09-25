# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe SumOfMembershipWeight do
      subject(:query_object) { described_class.new(relation) }

      let(:relation) do
        relation = Decidim::Consultations::Response
                   .joins(question: :consultation)
                   .where(question: question)
        Decidim::ActionDelegator::VotedWithPonderations.new(relation).query
      end

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
      let(:question) { create(:question, consultation: consultation) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:yet_other_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:response) { create(:response, question: question) }
      let(:setting) { create(:setting, consultation: consultation) }
      let(:ponderation1) { create(:ponderation, setting: setting, name: "foo", weight: 3) }
      let(:ponderation2) { create(:ponderation, setting: setting, name: "bar", weight: 2) }
      let(:votes_count) { query_object.query.map(&:votes_count) }

      before do
        question.votes.create(author: user, response: response)
        question.votes.create(author: other_user, response: response)
        question.votes.create(author: yet_other_user, response: response)
      end

      describe "#query" do
        it "returns responses and questions data" do
          expect(query_object.query.first.attributes).to eq(
            "id" => nil,
            "question_id" => question.id,
            "question_title" => question.title,
            "title" => response.title,
            "votes_count" => 3
          )
        end

        context "when all users have membership" do
          let!(:participant1) { create(:participant, ponderation: ponderation1, decidim_user: user, setting: setting) }
          let!(:participant2) { create(:participant, ponderation: ponderation1, decidim_user: other_user, setting: setting) }
          let!(:participant3) { create(:participant, ponderation: ponderation2, decidim_user: yet_other_user, setting: setting) }

          it "aggregates their membership weights" do
            expect(votes_count).to eq([(2 * ponderation1.weight) + ponderation2.weight])
          end
        end

        context "when some users have no membership" do
          let!(:participant1) { create(:participant, ponderation: ponderation1, decidim_user: user, setting: setting) }

          it "aggregates blank votes as a single one" do
            expect(votes_count).to eq([ponderation1.weight + 2])
          end
        end
      end
    end
  end
end
