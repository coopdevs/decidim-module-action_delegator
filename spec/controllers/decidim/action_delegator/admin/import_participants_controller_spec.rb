# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    module Admin
      describe ImportParticipantsController do
        routes { Decidim::ActionDelegator::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_setting"] = setting
          sign_in current_user
        end

        describe "GET #new" do
          let(:setting) { create(:setting, consultation: consultation, authorization_method: authorization_method) }
          let(:authorization_method) { :both }

          before do
            get :new, params: { setting_id: setting.id }
          end

          it "returns a success response" do
            expect(response).to be_successful
          end

          it "assigns an empty array of errors" do
            expect(assigns(:errors)).to eq []
          end
        end
      end
    end
  end
end
