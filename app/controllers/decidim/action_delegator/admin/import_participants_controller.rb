# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ImportParticipantsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission
        include Decidim::Paginable

        helper ::Decidim::ActionDelegator::Admin::DelegationHelper
        helper_method :organization_settings, :current_setting

        layout "decidim/action_delegator/admin/delegations"

        def new
          enforce_permission_to :create, :participant

          @errors = []
        end

        def create
          enforce_permission_to :create, :participant

          @csv_file = params[:csv_file]
          redirect_to import_participants_path && return if @csv_file.blank?

          @import_summary = Decidim::ActionDelegator::Admin::ImportParticipantsCsvJob.perform_now(
            current_user,
            @csv_file.read.force_encoding("utf-8").encode("utf-8"),
            current_setting
          )

          flash[:notice] = t(".success",
                             total_rows_count: @import_summary[:total_rows],
                             rows_imported: @import_summary[:imported_rows],
                             error_rows: @import_summary[:error_rows].count)

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
