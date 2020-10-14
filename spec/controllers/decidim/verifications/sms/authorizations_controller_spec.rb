# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module Sms
      describe AuthorizationsController, type: :controller do
        routes { Decidim::Verifications::Sms::Engine.routes }

        let(:organization) { create :organization }
        let(:user) { create(:user, :confirmed, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user
        end

        describe "get #new" do
          context "when membership_phone is missing" do
            it "shows missing_phone_error" do
              get :new
              expect(response).to have_http_status(:ok)
              expect(controller).to set_flash.now[:error].to(I18n.t("decidim.action_delegator.authorizations.new.missing_phone_error"))
            end
          end

          context "when membership_phone is set" do
            let!(:authorization) { create(:authorization, user: user, name: "direct_verifications", metadata: metadata) }
            let(:metadata) { { membership_phone: membership_phone } }
            let(:membership_phone) { "+12 345 678" }

            it "does not show missing_phone_error" do
              get :new
              expect(response).to have_http_status(:ok)
              expect(controller).not_to set_flash.now[:error].to(I18n.t("decidim.action_delegator.authorizations.new.missing_phone_error"))
            end

            it "initializes the MobilePhoneForm with the membership_phone" do
              allow(Decidim::Verifications::Sms::MobilePhoneForm).to receive(:new).with(mobile_phone_number: membership_phone)
              get :new
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end
end
