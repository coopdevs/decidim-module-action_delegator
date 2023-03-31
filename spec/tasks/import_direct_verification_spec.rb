# frozen_string_literal: true

require "spec_helper"

describe "rake action_delegator:import_direct_verifications", type: :task do
  let(:user1) { create(:user, :confirmed) }
  let(:user2) { create(:user, :confirmed, organization: user1.organization) }
  let(:user3) { create(:user, :confirmed) }
  let(:user4) { create(:user, :confirmed, organization: user3.organization) }
  let(:user5) { create(:user, :confirmed, organization: user3.organization) }
  let!(:authorization1) { create(:authorization, :direct_verification, user: user1, metadata: metadata1) }
  let!(:authorization2) { create(:authorization, :direct_verification, user: user2, metadata: metadata2) }
  let!(:authorization3) { create(:authorization, :direct_verification, user: user3, metadata: metadata3) }
  let!(:authorization4) { create(:authorization, :direct_verification, user: user4, metadata: metadata4) }
  let!(:authorization5) { create(:authorization, :direct_verification, user: user5, metadata: metadata5) }
  let(:metadata1) { { membership_type: "producer", membership_weight: 2, membership_phone: "1234" } }
  let(:metadata2) { { membership_type: "consumer", membership_weight: 1.5, membership_phone: "23456" } }
  let(:metadata3) { { membership_type: "user1", membership_weight: 1 } }
  let(:metadata4) { { membership_type: "user2", membership_weight: 2 } }
  let(:metadata5) { { membership_type: "user2", membership_weight: 2 } }
  let(:consultation1) { create(:consultation, organization: user1.organization) }
  let(:consultation2) { create(:consultation, organization: user3.organization) }
  let!(:setting1) { create(:setting, consultation: consultation1) }
  let!(:setting2) { create(:setting, consultation: consultation2) }

  context "when executing task" do
    it "have to be executed without failures" do
      expect { task.execute }.not_to raise_error
    end

    it "create participants" do
      expect { task.execute }.to change { Decidim::ActionDelegator::Participant.count }.by(5)
    end

    it "create weights" do
      expect { task.execute }.to change { Decidim::ActionDelegator::Ponderation.count }.by(4)
    end

    context "when output" do
      before { task.execute }

      it "shows info" do
        check_message_printed <<~HEREDOC
          Processing organization [#{user1.organization.name}]
          Found 2 authorizations
        HEREDOC
        check_message_printed <<~HEREDOC
          Processing organization [#{user3.organization.name}]
          Found 3 authorizations
        HEREDOC
        check_message_printed("Imported authorization [#{authorization1.id}] into participant [#{user1.email}] with ponderation [producer (x2.0)]")
        check_message_printed("Imported authorization [#{authorization2.id}] into participant [#{user2.email}] with ponderation [consumer (x1.5)]")
        check_message_printed("Imported authorization [#{authorization3.id}] into participant [#{user3.email}] with ponderation [user1 (x1.0)]")
        check_message_printed("Imported authorization [#{authorization4.id}] into participant [#{user4.email}] with ponderation [user2 (x2.0)]")
        check_message_printed("Imported authorization [#{authorization5.id}] into participant [#{user5.email}] with ponderation [user2 (x2.0)]")
        check_message_printed("Imported 2 authorizations")
        check_message_printed("Imported 3 authorizations")
      end
    end
  end
end
