# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe DelegationVotes do
    let(:organization) { create(:organization) }
    let(:other_organization) { create(:organization) }

    let(:consultation) { create(:consultation, organization: organization) }

    let(:question) { create(:question, consultation: consultation) }
    let(:other_question) { create(:question, consultation: consultation) }

    let(:granter) { create(:user, organization: organization) }

    let!(:delegation) { create(:delegation, granter: granter) }
    let!(:other_delegation) { create(:delegation, granter: granter) }

    before do
      create(:vote, author: granter, question: question)
      create(:vote, author: granter, question: other_question)
    end

    describe "#query" do
      it "returns the votes of all delegations" do
        results = DelegationVotes.new.query.map do |result|
          result.slice(:id, :granter_id, :decidim_action_delegator_setting_id).symbolize_keys
        end

        expect(results).to contain_exactly(
          {
            id: delegation.id,
            granter_id: granter.id,
            decidim_action_delegator_setting_id: delegation.setting.id
          },
          {
            id: other_delegation.id,
            granter_id: granter.id,
            decidim_action_delegator_setting_id: other_delegation.setting.id
          },
          {
            id: delegation.id,
            granter_id: granter.id,
            decidim_action_delegator_setting_id: delegation.setting.id
          },
          { # rubocop:disable Style/BracesAroundHashParameters
            id: other_delegation.id,
            granter_id: granter.id,
            decidim_action_delegator_setting_id: other_delegation.setting.id
          }
        )
      end
    end
  end
end
