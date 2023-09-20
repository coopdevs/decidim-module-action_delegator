# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    module Admin
      describe ManageParticipantsController do
        routes { Decidim::ActionDelegator::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let(:consultation) { create(:consultation, organization: organization) }
        let(:setting) { create(:setting, consultation: consultation, authorization_method: authorization_method) }
        let(:authorization_method) { :both }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_setting"] = setting
          sign_in current_user
        end

        describe "GET #new" do
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

        describe "DELETE #destroy_all" do
          let(:question) { create(:question, consultation: consultation) }
          let(:response) { create(:response, question: question) }
          let!(:vote) { create(:vote, question: question, response: response) }
          let!(:participants) { create_list(:participant, 3, setting: setting) }

          let(:params) do
            { setting_id: setting.id }
          end

          it "authorizes the action" do
            expect(controller).to receive(:allowed_to?).with(:destroy, :participant, { resource: setting })

            get :destroy_all, params: params
          end

          it "removes all and redirects to the participants page" do
            expect { delete :destroy_all, params: params }.to change(Participant, :count).by(-3)
            expect(flash[:notice]).to eq(I18n.t("participants.remove_census.success", scope: "decidim.action_delegator.admin", participants_count: participants.count))
            expect(response).to redirect_to(setting_participants_path(setting))
          end

          context "when participant has voted" do
            let!(:participant) { create(:participant, setting: setting, decidim_user: current_user) }
            let!(:vote) { create(:vote, question: question, response: response, author: current_user) }

            it "does not remove the voted participants" do
              expect { delete :destroy_all, params: params }.to change(Participant, :count).by(-3)
              expect(flash[:notice]).to eq(I18n.t("participants.remove_census.success", scope: "decidim.action_delegator.admin", participants_count: participants.count))
              expect(response).to redirect_to(setting_participants_path(setting))
            end
          end
        end
      end
    end
  end
end
