# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::CreateSetting do
  subject { described_class.new(form, selected_setting) }

  let(:max_grants) { 10 }
  let(:selected_setting) { nil }
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

  context "when copy setting" do
    let!(:selected_setting) { create(:setting, :with_participants, :with_ponderations, consultation: other_consultation) }
    let(:other_consultation) { create(:consultation) }
    let(:form) do
      double(
        invalid?: invalid,
        max_grants: max_grants,
        authorization_method: authorization_method,
        decidim_consultation_id: decidim_consultation_id,
        source_consultation_id: selected_setting.id
      )
    end

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates a setting" do
      expect { subject.call }.to(change { Decidim::ActionDelegator::Setting.count }.by(1))
    end
  end
end
