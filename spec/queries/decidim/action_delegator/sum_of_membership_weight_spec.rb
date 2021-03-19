# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe SumOfMembershipWeight do
      subject(:query_object) { described_class.new(relation) }

      let(:relation) do
        relation = Decidim::Consultations::Response.where(question: question)
        Decidim::ActionDelegator::VotedWithDirectVerification.new(relation).query
      end

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
      let(:question) { create(:question, consultation: consultation) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:response) { create(:response, question: question) }

      before do
        question.votes.create(author: user, response: response)
        question.votes.create(author: other_user, response: response)
      end

      describe "#query" do
        context "when all users have membership" do
          let(:auth_metadata) { { membership_type: "producer", membership_weight: 2 } }
          let(:other_auth_metadata) { { membership_type: "producer", membership_weight: 3 } }

          before do
            create(:authorization, :direct_verification, user: user, metadata: auth_metadata)
            create(:authorization, :direct_verification, user: other_user, metadata: other_auth_metadata)
          end

          it "aggregates their membership weights" do
            result_set = query_object.query

            expect(result_set.first.votes_count)
              .to eq(auth_metadata[:membership_weight] + other_auth_metadata[:membership_weight])
          end
        end

        context "when some users have no membership" do
          let(:auth_metadata) { { membership_type: "producer", membership_weight: 2 } }

          before do
            create(:authorization, :direct_verification, user: user, metadata: auth_metadata)
          end

          it "aggregates their vote as a single one" do
            result_set = query_object.query

            expect(result_set.first.votes_count).to eq(auth_metadata[:membership_weight] + 1)
          end
        end
      end
    end
  end
end
