# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::SettingForm do
  subject { described_class.from_params(attributes) }

  let(:consultation) { create(:consultation) }
  let(:attributes) do
    {
      decidim_consultation_id: consultation.id,
      max_grants: 5,
      verify_with_sms: true,
      phone_freezed: true
    }
  end

  it { is_expected.to be_valid }

  context "when decidim_consultation_id is missing" do
    let(:attributes) { super().except(:decidim_consultation_id) }

    it { is_expected.to be_invalid }
  end

  context "when max_grants is missing" do
    let(:attributes) { super().except(:max_grants) }

    it { is_expected.to be_invalid }
  end

  context "when decidim_consultation_id is already taken" do
    let!(:setting) { create(:setting, decidim_consultation_id: consultation.id) }

    it { is_expected.to be_invalid }
  end
end
