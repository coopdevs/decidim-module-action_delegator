# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::CreateSetting do
  subject { described_class.new(form) }

  let(:max_grants) { 10 }
  let(:verify_with_sms) { true }
  let(:phone_freezed) { true }
  let(:decidim_consultation_id) { create(:consultation).id }
  let(:invalid) { false }

  let(:form) do
    double(
      invalid?: invalid,
      max_grants: max_grants,
      verify_with_sms: verify_with_sms,
      phone_freezed: phone_freezed,
      decidim_consultation_id: decidim_consultation_id
    )
  end

  it "broadcasts :ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "creates a setting" do
    expect { subject.call }.to(change { Decidim::ActionDelegator::Setting.count }.by(1))
  end

  context "when the form is invalid" do
    let(:invalid) { true }

    it "broadcasts :invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "doesn't create a setting" do
      expect { subject.call }.not_to(change { Decidim::ActionDelegator::Setting.count })
    end
  end
end
