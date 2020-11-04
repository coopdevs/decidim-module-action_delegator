# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe DelegatedVotesVersions do
    subject { described_class.new(consultation) }

    let(:organization) { create :organization }
    let(:user) { create(:user, :confirmed, organization: organization) }

    let(:consultation) { create(:consultation, organization: organization) }
    let(:question) { create(:question, consultation: consultation) }
    let(:setting) { create(:setting, consultation: consultation) }
    let(:delegation) { create(:delegation, setting: setting, granter: user) }
    let!(:vote) { create(:vote, author: delegation.granter, question: question) }

    let!(:other_consultation) { create(:consultation, organization: organization) }
    let(:other_question) { create(:question, consultation: other_consultation) }
    let(:other_setting) { create(:setting, consultation: other_consultation) }
    let!(:other_delegation) { create(:delegation, setting: other_setting, granter: user) }
    let!(:other_vote) { create(:vote, author: other_delegation.granter, question: other_question) }

    before do
      PaperTrail::Version.create!(
        item_type: "Decidim::Consultations::Vote",
        item_id: vote.id,
        event: "create",
        decidim_action_delegator_delegation_id: delegation.id
      )
    end

    describe "#query", versioning: true do
      it "enables fetching all versions related to a consultation" do
        result = subject.query
        version = vote.versions.last

        expect(result.size).to eq(1)
        expect(result.first).to include(version.attributes.slice(:id))
      end
    end
  end
end
