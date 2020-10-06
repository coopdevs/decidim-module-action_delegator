# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Permissions < Decidim::DefaultPermissions
      SUBJECTS_WHITELIST = [:delegation, :setting, :consultation].freeze

      def permissions
        return permission_action unless user.admin?
        return permission_action unless permission_action.scope == :admin
        return permission_action unless action_delegator_subject?

        allow! if consultation_results_exports_action? || can_perform_action?

        permission_action
      end

      private

      def consultation_results_exports_action?
        permission_action.subject == :consultation && permission_action.action == :export_results
      end

      def action_delegator_subject?
        SUBJECTS_WHITELIST.include?(permission_action.subject)
      end

      def can_perform_action?
        if permission_action.action == :destroy
          resource.present?
        else
          true
        end
      end

      def resource
        @resource ||= context.fetch(:resource, nil)
      end
    end
  end
end
