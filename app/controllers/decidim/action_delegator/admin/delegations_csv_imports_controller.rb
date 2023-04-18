# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class DelegationsCsvImportsController < ActionDelegator::Admin::ApplicationController
        helper DelegationHelper
        helper_method :current_setting

        layout "decidim/admin/users"

        def new
          enforce_permission_to :csv_import, :setting

          @form = form(DelegationsCsvImportForm).instance
          render template: "decidim/action_delegator/admin/settings/csv_import/new"
        end

        def create
          enforce_permission_to :csv_import, :setting
          @form = form(DelegationsCsvImportForm).from_params(params)

          ImportDelegationsCsv.call(@form, current_user, current_setting) do
            on(:ok) do
              flash[:notice] = I18n.t(".delegations.csv_imports.success", scope: "decidim.action_delegator.admin")
              redirect_to setting_delegations_path(current_setting)
            end

            on(:invalid) do
              flash[:alert] = I18n.t(".delegations.csv_imports.invalid", scope: "decidim.action_delegator_admin")
              render template: "decidim/admin/delegations_csv_imports/new"
            end
          end
        end

        private

        def current_setting
          @current_setting ||= organization_settings.find_by(id: params[:setting_id])
        end

        def organization_settings
          ActionDelegator::OrganizationSettings.new(current_organization).query
        end
      end
    end
  end
end
