# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::VoteDelegation do
  subject { described_class.new(response, context) }

  let(:organization) { build(:organization) }
  let(:consultation) { build(:consultation, :active, organization: organization) }
  let(:setting) { build(:setting, consultation: consultation) }
  let(:delegation) { build(:delegation, setting: setting) }
  let(:question) { build(:question, :published, consultation: consultation) }
  let(:response) { build(:response, question: question) }

  let(:context) { double(:context, delegation: delegation, current_question: question, current_user: delegation.grantee) }

  shared_examples "delegation tracking" do |save_method|
    it "tracks who performed the vote", versioning: true do
      vote = subject.call
      vote.send(save_method)

      expect(vote.versions.last.whodunnit).to eq(context.current_user.id.to_s)
    end

    it "tracks the delegation the vote is related to", versioning: true do
      delegation.save
      question.save

      vote = subject.call
      vote.send(save_method)

      expect(vote.versions.last.decidim_action_delegator_delegation_id).to eq(delegation.id)
    end
  end

  describe "#call" do
    it "builds a vote with the granter as author" do
      vote = subject.call
      expect(vote.author).to eq(delegation.granter)
    end

    it "builds a vote with the response taken from the initializer" do
      vote = subject.call
      expect(vote.response).to eq(response)
    end

    it "builds a valid vote" do
      vote = subject.call
      expect(vote).to be_valid
    end

    it_behaves_like "delegation tracking", "save"
    it_behaves_like "delegation tracking", "save!"
  end
end
