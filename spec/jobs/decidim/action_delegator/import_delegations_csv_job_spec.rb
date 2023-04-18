# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe ImportDelegationsCsvJob do
      let!(:granter_email) { "granter@example.org" }
      let!(:grantee_email) { "grantee@example.org" }
      let!(:granter) { create(:user, email: granter_email) }
      let!(:grantee) { create(:user, email: grantee_email) }
      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, organization: organization) }
      let(:current_setting) { create(:setting, max_grants: 1) }

      describe "queue" do
        it "is queued to default" do
          expect(subject.queue_name).to eq "default"
        end
      end

      describe "#perform" do
        it "import delegations" do
          expect(Decidim::ActionDelegator::Admin::CreateDelegation).to receive(:call)
          described_class.perform_now(granter_email, grantee_email, current_user, current_setting)
        end
      end
    end
  end
end
