# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::SettingDelegations do
  subject { described_class.new(setting) }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:granter) { create(:user, organization: organization) }
  let(:grantee) { create(:user, organization: organization) }
  let(:other_user) { create(:user, organization: organization) }

  let!(:delegation) { create(:delegation, setting: setting, granter: granter, grantee: grantee) }
  let!(:other_delegation) { create(:delegation, setting: setting, granter: granter, grantee: other_user) }
  let!(:setting) { create(:setting, consultation: consultation) }
  let!(:other_setting) { create(:setting) }

  describe "#query" do
    it "returns the delegations of the specified setting only" do
      expect(subject.query).to match_array([delegation, other_delegation])
    end
  end
end
