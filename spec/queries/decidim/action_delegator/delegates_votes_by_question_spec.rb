# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::DelegatesVotesByQuestion do
  subject { described_class.new(question) }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:setting) { create(:setting, consultation: consultation) }
  let(:question) { create(:question, consultation: consultation) }

  let(:granter) { create(:user, organization: organization) }
  let!(:delegation) { create(:delegation, setting: setting, granter: granter) }
  let!(:delegated_vote) { create(:vote, author: granter, question: question) }

  let(:another_granter) { create(:user, organization: organization) }
  let!(:another_delegation) { create(:delegation, setting: setting, granter: another_granter) }
  let!(:another_delegated_vote) { create(:vote, author: another_granter, question: question) }

  describe "#query" do
    it "total votes count is correct" do
      expect(subject.query).to eq(2)
    end
  end
end
