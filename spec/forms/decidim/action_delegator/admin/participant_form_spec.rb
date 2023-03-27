# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::ParticipantForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      setting: setting
    }
  end
  let(:setting) { create(:setting, :with_ponderations) }
  let(:attributes) do
    {
      email: email,
      phone: phone,
      decidim_action_delegator_ponderation_id: decidim_action_delegator_ponderation_id
    }
  end
  let(:email) { "example@example.org" }
  let(:phone) { "123456789" }
  let(:decidim_action_delegator_ponderation_id) { setting.ponderations.first.id }

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when email is not present" do
    let(:email) { nil }

    it { is_expected.not_to be_valid }
  end

  context "when phone is not present" do
    let(:phone) { nil }

    it { is_expected.to be_valid }
  end

  context "when ponderation is not present" do
    let(:decidim_action_delegator_ponderation_id) { nil }

    it { is_expected.to be_valid }

    context "and ponderation belongs to a differnt setting" do
      let(:decidim_action_delegator_ponderation_id) { create(:ponderation).id }

      it { is_expected.not_to be_valid }
    end
  end
end
