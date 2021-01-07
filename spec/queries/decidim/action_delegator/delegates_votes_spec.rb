# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::DelegatesVotes do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:question) { create(:question, consultation: consultation) }
  let(:setting) { create(:setting, consultation: consultation) }

  let(:granter) { create(:user, organization: organization) }
  let!(:delegation) { create(:delegation, setting: setting, granter: granter) }
  let!(:delegated_vote) { create(:vote, author: granter, question: question) }
  let(:authors_ids_votes) { [granter.id] }

  describe "#query" do
    it "return some users" do
      expect(Decidim::ActionDelegator::DelegatesVotes.new(authors_ids_votes).query.count).to eq(1)
    end
  end
end
