# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::PonderationForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:context) do
    {
      setting: setting
    }
  end
  let(:setting) { create(:setting) }
  let(:attributes) do
    {
      weight: weight,
      name: name
    }
  end

  let(:weight) { 1.0 }

  let(:name) { "Ponderation name" }

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when weight is not present" do
    let(:weight) { nil }

    it { is_expected.not_to be_valid }
  end

  context "when name is not present" do
    let(:name) { nil }

    it { is_expected.not_to be_valid }
  end

  context "when name is not unique" do
    let!(:existing_ponderation) { create(:ponderation, name: name, setting: setting) }

    it { is_expected.not_to be_valid }

    context "and the setting is different" do
      let!(:existing_ponderation) { create(:ponderation, name: name) }

      it { is_expected.to be_valid }
    end
  end
end
