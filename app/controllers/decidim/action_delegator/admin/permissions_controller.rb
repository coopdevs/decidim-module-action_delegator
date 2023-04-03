# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class PermissionsController < ActionDelegator::Admin::ApplicationController
        def create
          enforce_permission_to :update, :setting
          return redirect_to decidim_admin_action_delegator.settings_path unless setting&.consultation

          FixResourcePermissions.call(setting.consultation.questions) do
            on(:ok) do
              notice = I18n.t("permissions.update.success", scope: "decidim.action_delegator.admin")
              redirect_to decidim_admin_action_delegator.settings_path, notice: notice
            end

            on(:invalid) do |_error|
              flash.now[:error] = I18n.t("permissions.update.error", scope: "decidim.action_delegator.admin")
              render :new
            end
          end
        end

        private

        def setting
          @setting ||= Decidim::ActionDelegator::Setting.find(params[:setting_id])
        end
      end
    end
  end
end
