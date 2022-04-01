# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This controller handles user profile actions for this module
    class UserDelegationsController < ActionDelegator::ApplicationController
      include Decidim::UserProfile

      helper_method :delegations

      def index
        enforce_permission_to :read, :user, current_user: current_user
      end

      private

      def delegations
        @delegations ||= Delegation.where(grantee_id: current_user.id)
      end
    end
  end
end
