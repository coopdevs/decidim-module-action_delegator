# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::DelegationForm do
  subject { described_class.from_params(attributes).with_context(current_organization: organization) }

  let(:organization) { create(:organization) }
  let(:granter) { create(:user, organization: organization) }
  let(:grantee) { create(:user, organization: organization) }
  let(:granter_email) { nil }
  let(:grantee_email) { nil }
  let(:attributes) do
    {
      granter_id: granter&.id,
      grantee_id: grantee&.id,
      granter_email: granter_email,
      grantee_email: grantee_email
    }
  end
  let!(:granter_user) { create(:user, organization: organization) }
  let!(:grantee_user) { create(:user, organization: organization) }

  context "when there's granter and grantee" do
    it { is_expected.to be_valid }

    context "when granter belongs to another organization" do
      let(:granter) { create(:user) }

      it { is_expected.not_to be_valid }
    end

    context "when grantee belongs to another organization" do
      let(:grantee) { create(:user) }

      it { is_expected.not_to be_valid }
    end
  end

  context "when granter is missing" do
    let(:granter) { nil }

    it { is_expected.not_to be_valid }

    context "and granter_email is present" do
      let(:granter_email) { granter_user.email }

      it { is_expected.to be_valid }

      context "and granter is not registered" do
        let(:granter_email) { "test@idontexist.com" }

        it { is_expected.not_to be_valid }
      end
    end
  end

  context "when grantee is missing" do
    let(:grantee) { nil }

    it { is_expected.not_to be_valid }

    context "and grantee_email is present" do
      let(:grantee_email) { grantee_user.email }

      it { is_expected.to be_valid }

      context "and grantee is not registered" do
        let(:grantee_email) { "test@idontexist.com" }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
