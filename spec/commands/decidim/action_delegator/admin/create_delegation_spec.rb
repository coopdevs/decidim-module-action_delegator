# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::CreateDelegation do
  subject { described_class.new(form, current_user) }

  let(:current_user) { create(:user, organization: organization) }
  let(:current_setting) { create(:setting, max_grants: 1) }
  let(:organization) { create(:organization) }
  let(:granter) { create(:user, organization: organization) }
  let(:grantee) { create(:user, organization: organization) }

  let(:form) do
    double(
      invalid?: invalid,
      grantee_id: grantee.id,
      granter_id: granter.id,
      setting: current_setting,
      attributes: {
        grantee_id: grantee.id,
        granter_id: granter.id,
        setting: current_setting
      },
      errors: double(add: true)
    )
  end

  let(:invalid) { false }

  context "when form is valid" do
    context "when current_user is not the granter" do
      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end

    context "when current_user self delegates" do
      let(:grantee) { current_user }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when max_grant reaches limit" do
      before do
        create(:delegation, form.attributes)
      end

      it "broadcasts :above_max_grants" do
        expect { subject.call }.to broadcast(:above_max_grants)
      end
    end
  end

  context "when form is invalid" do
    let(:invalid) { true }

    it "broadcasts :invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
