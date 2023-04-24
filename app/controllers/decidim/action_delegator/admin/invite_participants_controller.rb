# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class InviteParticipantsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission

        helper_method :current_setting, :users_list_to_invite, :participant

        def invite_user
          @form = form(RegistrationForm).from_model(participant)

          InviteUser.call(@form, participant) do
            on(:ok) do
              notice = t("invite_user.success", scope: "decidim.action_delegator.admin.invite_participants")
              redirect_to decidim_admin_action_delegator.setting_participants_path(current_setting), notice: notice
            end

            on(:invalid) do |_error|
              flash.now[:error] = t("invite_user.error", scope: "decidim.action_delegator.admin.invite_participants")
            end
          end
        end

        def invite_all_users
          users_list_to_invite.each do |participant|
            form = form(RegistrationForm).from_model(participant)
            InviteUser.call(form, participant)
          end

          notice = t("invite_all_users.success", scope: "decidim.action_delegator.admin.invite_participants")
          redirect_to decidim_admin_action_delegator.settings_path, notice: notice
        end

        def resend_invitation
          Decidim::InviteUserAgain.call(participant.user, "invite_participant") do
            on(:ok) do
              notice = t("resend_invitation.success", scope: "decidim.action_delegator.admin.invite_participants")
              redirect_to decidim_admin_action_delegator.setting_participants_path(current_setting), notice: notice
            end

            on(:invalid) do |_error|
              flash.now[:error] = t("resend_invitation.error", scope: "decidim.action_delegator.admin.invite_participants")
            end
          end
        end

        private

        def users_list_to_invite
          @users_list_to_invite ||= participants.where.not(email: Decidim::User.select(:email))
        end

        def current_setting
          @current_setting ||= organization_settings.find_by(id: params[:setting_id])
        end

        def participants
          @participants ||= current_setting.participants.where.not(email: "")
        end

        def participant
          @participant ||= participants.find_by(id: params[:id])
        end

        def organization_settings
          ActionDelegator::OrganizationSettings.new(current_organization).query
        end
      end
    end
  end
end
