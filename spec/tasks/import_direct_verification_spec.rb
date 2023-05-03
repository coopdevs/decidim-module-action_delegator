# frozen_string_literal: true

require "spec_helper"

describe "rake action_delegator:import_direct_verifications", type: :task do
  let(:user1) { create(:user, :confirmed) }
  let(:user2) { create(:user, :confirmed, organization: user1.organization) }
  let(:user3) { create(:user, :confirmed) }
  let(:user4) { create(:user, :confirmed, organization: user3.organization) }
  let(:user5) { create(:user, :confirmed, organization: user3.organization) }
  let!(:authorization1) { create(:authorization, name: "direct_verifications", user: user1, metadata: metadata1) }
  let!(:authorization2) { create(:authorization, name: "direct_verifications", user: user2, metadata: metadata2) }
  let!(:authorization3) { create(:authorization, name: "direct_verifications", user: user3, metadata: metadata3) }
  let!(:authorization4) { create(:authorization, name: "direct_verifications", user: user4, metadata: metadata4) }
  let!(:authorization5) { create(:authorization, name: "direct_verifications", user: user5, metadata: metadata5) }
  let(:metadata1) { { membership_type: "producer", membership_weight: 2, membership_phone: "1234" } }
  let(:metadata2) { { membership_type: "consumer", membership_weight: 1.5, membership_phone: "23456" } }
  let(:metadata3) { { membership_type: "user1", membership_weight: 1 } }
  let(:metadata4) { { membership_type: "user2", membership_weight: 2 } }
  let(:metadata5) { { membership_type: "user2", membership_weight: 2 } }
  let(:consultation1) { create(:consultation, organization: user1.organization) }
  let(:consultation2) { create(:consultation, organization: user3.organization) }
  let!(:setting1) { create(:setting, consultation: consultation1) }
  let!(:setting2) { create(:setting, consultation: consultation2) }
  let!(:ponderations1) { create_list(:ponderation, 2, setting: setting1) }
  let!(:ponderations2) { create_list(:ponderation, 3, setting: setting2) }

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

    context "when no current participants" do
      before { task.execute }

      it "shows info" do
        check_message_printed <<~HEREDOC
          Processing organization [#{user1.organization.name}]
          Found 2 authorizations
          Imported authorization [#{authorization1.id}] into participant [#{user1.email}] with ponderation [producer (x2.0)]
          Imported authorization [#{authorization2.id}] into participant [#{user2.email}] with ponderation [consumer (x1.5)]
          Imported 2 authorizations
        HEREDOC
        check_message_printed <<~HEREDOC
          Processing organization [#{user3.organization.name}]
          Found 3 authorizations
          Imported authorization [#{authorization3.id}] into participant [#{user3.email}] with ponderation [user1 (x1.0)]
          Imported authorization [#{authorization4.id}] into participant [#{user4.email}] with ponderation [user2 (x2.0)]
          Imported authorization [#{authorization5.id}] into participant [#{user5.email}] with ponderation [user2 (x2.0)]
          Imported 3 authorizations
        HEREDOC
      end
    end

    context "when there are current participants" do
      let!(:participant1) { create(:participant, setting: setting1, ponderation: setting1.ponderations.first, email: user1.email) }
      let!(:participant2) { create(:participant, setting: setting1, ponderation: setting1.ponderations.second, email: user2.email) }
      let!(:participant3) { create(:participant, setting: setting2, ponderation: setting2.ponderations.first, email: user3.email) }
      let!(:participant4) { create(:participant, setting: setting2, ponderation: setting2.ponderations.second, email: user4.email) }
      let!(:participant5) { create(:participant, setting: setting2, ponderation: setting2.ponderations.third, email: user5.email) }

      it "does not change current weights" do
        expect { task.execute }.not_to(change { Decidim::ActionDelegator::Ponderation.count })
      end

      it "does not change current participants" do
        expect { task.execute }.not_to(change { Decidim::ActionDelegator::Participant.count })
      end

      context "when using the command" do
        before { task.execute }

        it "does not change properties for the current participants" do
          expect(participant1.reload.ponderation).to eq(setting1.ponderations.first)
          expect(participant2.reload.ponderation).to eq(setting1.ponderations.second)
          expect(participant3.reload.ponderation).to eq(setting2.ponderations.first)
          expect(participant4.reload.ponderation).to eq(setting2.ponderations.second)
          expect(participant5.reload.ponderation).to eq(setting2.ponderations.third)
        end

        it "shows info" do
          check_message_printed <<~HEREDOC
            Processing organization [#{user1.organization.name}]
            Found 2 authorizations
            Imported 0 authorizations
          HEREDOC
          check_message_printed <<~HEREDOC
            Processing organization [#{user3.organization.name}]
            Found 3 authorizations
            Imported 0 authorizations
          HEREDOC
        end
      end
    end
  end
end
