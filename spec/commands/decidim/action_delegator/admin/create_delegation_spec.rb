# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::CreateDelegation do
  subject { described_class.new(form, current_user, current_setting) }

  let(:current_user) { create(:user, organization: organization) }
  let(:current_setting) { create(:setting, max_grants: 1) }
  let(:organization) { create(:organization) }
  let(:granter) { create(:user, organization: organization) }
  let(:grantee) { create(:user, organization: organization) }
  let(:other_grantee) { create(:user, organization: organization) }
  let(:other_granter) { create(:user, organization: organization) }

  let(:form) do
    double(
      invalid?: invalid,
      grantee_id: grantee.id,
      granter_id: granter.id,
      setting: current_setting,
      attributes: {
        granter_id: granter.id,
        grantee_id: grantee.id,
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

    context "when max_grant is 1" do
      context "when grantee has already a delegation" do
        before do
          create(:delegation, granter_id: other_granter.id, grantee_id: grantee.id, setting: current_setting)
        end

        it "broadcasts :error" do
          expect { subject.call }.to broadcast(:error)
        end
      end

      context "when grantee has no delegation" do
        before do
          create(:delegation, granter_id: other_granter.id, grantee_id: other_grantee.id, setting: current_setting)
        end

        it "does not broadcast :error" do
          expect { subject.call }.not_to broadcast(:error)
        end
      end
    end
  end

  context "when form is invalid" do
    let(:invalid) { true }

    it "broadcasts :error" do
      expect { subject.call }.to broadcast(:error)
    end
  end
end
