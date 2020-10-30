# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe Vote do
      subject { vote }

      let(:vote) { build :vote }

      it { is_expected.to be_versioned }

      describe "versions", versioning: true do
        context "when the vote comes from a delegation" do
          let(:organization) { create :organization }
          let(:user) { create(:user, :confirmed, organization: organization) }

          context "and the vote belongs to the delegation's consultation" do
            let(:consultation) { create(:consultation, organization: organization) }
            let(:question) { create(:question, consultation: consultation) }
            let(:setting) { create(:setting, consultation: consultation) }

            let(:delegation) { create(:delegation, setting: setting, granter: user) }
            let!(:vote) { create(:vote, author: delegation.granter, question: question) }

            it "stores the delegation id" do
              version = vote.versions.last
              expect(version.decidim_action_delegator_delegation_id).to eq(delegation.id)
            end
          end

          context "and the vote does not belong to the delegation's consultation" do
            let(:consultation) { create(:consultation, organization: organization) }
            let(:setting) { create(:setting, consultation: consultation) }
            let(:delegation) { create(:delegation, setting: setting, granter: user) }

            let(:other_consultation) { create(:consultation, organization: organization) }
            let(:other_question) { create(:question, consultation: other_consultation) }
            let!(:vote) { create(:vote, author: delegation.granter, question: other_question) }

            it "does not store the delegation id" do
              version = vote.versions.last
              expect(version.decidim_action_delegator_delegation_id).to be_nil
            end
          end
        end

        context "when the vote does not come from a delegation" do
          let!(:vote) { create(:vote) }

          it "does not store the delegation id" do
            version = vote.versions.last
            expect(version.decidim_action_delegator_delegation_id).to be_nil
          end
        end
      end
    end
  end
end
