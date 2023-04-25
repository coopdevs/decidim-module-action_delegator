# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class InviteParticipantsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission

        helper_method :current_setting, :users_list_to_invite, :participant, :form

        def invite_user
          enforce_permission_to :invite, :participant, resource: current_setting

          Decidim::InviteUser.call(form) do
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
          enforce_permission_to :invite, :participant, resource: current_setting

          users_list_to_invite.each do |participant|
            InviteParticipantsJob.perform_later(participant, current_organization)
          end

          notice = t("invite_all_users.success", scope: "decidim.action_delegator.admin.invite_participants")
          redirect_to decidim_admin_action_delegator.setting_participants_path(current_setting), notice: notice
        end

        def resend_invitation
          enforce_permission_to :invite, :participant, resource: current_setting

          Decidim::InviteUserAgain.call(participant.user, "invitation_instructions") do
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
          @users_list_to_invite ||= participants.where.not(email: current_organization.users.select(:email))
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

        def build_form(participant)
          Decidim::ActionDelegator::Admin::InvitationParticipantForm.new(
            name: participant.email.split("@").first&.gsub(/\W/, ""),
            email: participant.email.downcase,
            organization: current_organization,
            admin: false,
            invited_by: current_user
          )
        end

        def form
          @form ||= build_form(participant)
        end
      end
    end
  end
end
