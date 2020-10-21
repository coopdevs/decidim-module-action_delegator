# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Permissions < Decidim::DefaultPermissions
      SUBJECTS_WHITELIST = [:delegation, :setting, :consultation].freeze

      def permissions
        allowed_delegation_action?

        return permission_action unless user.admin?
        return permission_action unless permission_action.scope == :admin
        return permission_action unless action_delegator_subject?

        if permission_action.action == :export_consultation_results
          allow! if consultation.results_published?
        elsif can_perform_action?
          allow!
        end

        permission_action
      end

      private

      def allowed_delegation_action?
        return unless delegation
        # Check that the required question verifications are fulfilled
        return unless authorized?(:vote, delegation.grantee)

        case permission_action.action
        when :vote_delegation
          toggle_allow(question.can_be_voted_by?(delegation.granter) && delegation.grantee == user)
        when :unvote_delegation
          toggle_allow(question.can_be_unvoted_by?(delegation.granter) && delegation.grantee == user)
        end
      end

      def authorized?(permission_action, user, resource: nil)
        return unless resource || question

        ActionAuthorizer.new(user, permission_action, question, resource).authorize.ok?
      end

      def question
        @question ||= context.fetch(:question, nil)
      end

      def delegation
        @delegation ||= context.fetch(:delegation, nil)
      end

      def consultation_results_exports_action?
        permission_action.subject == :consultation && permission_action.action == :export_results
      end

      def consultation
        @consultation ||= context.fetch(:consultation)
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
