# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Delegation < ApplicationRecord
      self.table_name = "decidim_action_delegator_delegations"

      belongs_to :granter, class_name: "Decidim::User"
      belongs_to :grantee, class_name: "Decidim::User"
      belongs_to :setting,
                 foreign_key: "decidim_action_delegator_setting_id",
                 class_name: "Decidim::ActionDelegator::Setting"

      validates :granter, uniqueness: {
        scope: [:setting],
        message: I18n.t("delegations.create.error_granter_unique", scope: "decidim.action_delegator.admin")
      }

      delegate :consultation, to: :setting

      before_destroy { |record| throw(:abort) if record.voted? }

      def self.granted_to?(user, consultation)
        GranteeDelegations.for(consultation, user).exists?
      end

      def voted?
        return false unless consultation.questions.any?

        @voted ||= if consultation.questions&.detect { |question| question.voted_by?(granter) }
                     true
                   else
                     false
                   end
      end
    end
  end
end
