# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::UpdateSetting do
  subject { described_class.new(form, setting) }

  let(:setting) { create(:setting, max_grants: 10) }
  let(:max_grants) { 9 }
  let(:authorization_method) { :both }
  let(:decidim_consultation_id) { create(:consultation).id }
  let(:invalid) { false }

  let(:form) do
    double(
      invalid?: invalid,
      max_grants: max_grants,
      authorization_method: authorization_method,
      decidim_consultation_id: decidim_consultation_id
    )
  end

  it "broadcasts :ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates the setting" do
    expect { subject.call }.to(change { setting.reload.max_grants }.from(10).to(9))
  end

  context "when the form is invalid" do
    let(:invalid) { true }

    it "broadcasts :invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "doesn't update a Setting" do
      expect { subject.call }.not_to(change { setting.reload.max_grants })
    end
  end
end
