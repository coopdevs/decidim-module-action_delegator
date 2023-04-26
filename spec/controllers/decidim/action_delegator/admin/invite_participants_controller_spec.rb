# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    module Admin
      describe InviteParticipantsController do
        routes { Decidim::ActionDelegator::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let(:setting) { create(:setting, consultation: consultation) }
        let(:consultation) { create(:consultation, organization: organization) }
        let(:participant) { create(:participant, setting: setting) }
        let(:form) do
          double(
            name: participant.email.split("@").first.delete("^A-Za-z"),
            email: participant.email.downcase,
            organization: organization,
            admin: false,
            invited_by: user
          )
        end

        let(:params) do
          { setting_id: setting.id,
            id: participant.id,
            participant: participant }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user
        end

        describe "POST #invite_user" do
          context "when invite the one user" do
            it "invites the user and redirects to the participants page" do
              post :invite_user, params: params

              expect(response).to redirect_to setting_participants_path(setting)
              expect(flash[:notice]).to eq(I18n.t("invite_user.success", scope: "decidim.action_delegator.admin.invite_participants"))
            end
          end
        end

        describe "POST #invite_all_users" do
          context "when invite all users" do
            let!(:users_list_to_invite) { create_list(:participant, 3, setting: setting) }

            it "invites all users and redirects to the participants page" do
              post :invite_all_users, params: { setting_id: setting.id }

              expect(response).to redirect_to setting_participants_path(setting)
              expect(flash[:notice]).to eq(I18n.t("invite_all_users.success", scope: "decidim.action_delegator.admin.invite_participants"))
            end
          end
        end

        describe "POST #resend_invitation" do
          let!(:participant) { create(:participant, setting: setting, decidim_user_id: user.id) }

          context "when :ok" do
            before do
              post :invite_user, params: params
            end

            it "resends invitation to the participant" do
              post :resend_invitation, params: params

              expect(response).to redirect_to setting_participants_path(setting)
              expect(flash[:notice]).to eq(I18n.t("users.resend_invitation.success", scope: "decidim.admin"))
            end
          end
        end
      end
    end
  end
end
