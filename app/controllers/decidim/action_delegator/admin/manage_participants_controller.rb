# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ManageParticipantsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission
        include Decidim::Paginable

        helper ::Decidim::ActionDelegator::Admin::DelegationHelper
        helper_method :organization_settings, :current_setting

        layout "decidim/admin/users"

        def new
          enforce_permission_to :create, :participant

          @errors = []
        end

        def create
          enforce_permission_to :create, :participant

          @csv_file = params[:csv_file]
          redirect_to seting_manage_participants_path && return if @csv_file.blank?

          @import_summary = Decidim::ActionDelegator::Admin::ImportParticipantsCsvJob.perform_later(
            current_user,
            @csv_file.read.force_encoding("utf-8").encode("utf-8"),
            current_setting
          )

          flash[:notice] = t(".success")

          redirect_to decidim_admin_action_delegator.setting_participants_path(current_setting)
        end

        private

        def current_setting
          @current_setting ||= organization_settings.find_by(id: params[:setting_id])
        end

        def organization_settings
          Decidim::ActionDelegator::OrganizationSettings.new(current_organization).query
        end
      end
    end
  end
end
