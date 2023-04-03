# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module PermissionsOverride
        extend ActiveSupport::Concern

        included do
          private

          # Overrides Decidim::Consultations::Permissions to account for delegation votes
          def allowed_public_action?
            return unless permission_action.scope == :public
            return unless permission_action.subject == :question

            # check if question has been limited by admins first
            return unless authorized? :vote

            case permission_action.action
            when :vote
              toggle_allow(question.can_be_voted_by?(user) || can_be_delegated?(user))
            when :unvote
              toggle_allow(question.can_be_unvoted_by?(user))
            end
          end

          def can_be_delegated?(user)
            Delegation.granted_to?(user, question.consultation)
          end
        end
      end
    end
  end
end
