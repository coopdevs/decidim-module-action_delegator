# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe GranteeDelegations do
      subject { described_class.new(consultation, user) }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, organization: organization) }
      let(:user) { create(:user, organization: organization) }
      let(:other_user) { create(:user, organization: organization) }
      let(:setting) { create(:setting, consultation: consultation) }

      let!(:delegation) { create(:delegation, setting: setting, grantee: user) }
      let!(:other_grantee_delegation) { create(:delegation, setting: setting, grantee: other_user) }

      it "returns delegations where user is grantee" do
        expect(subject.query.map(&:id)).to eq([delegation.id])
      end
    end
  end
end
