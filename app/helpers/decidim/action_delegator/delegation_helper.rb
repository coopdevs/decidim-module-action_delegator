# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module DelegationHelper
      def has_any_delegate_vote?(question)
        Decidim::ActionDelegator::GranteeDelegations.for(question.consultation, current_user).detect do |delegation|
          question.voted_by?(delegation.granter)
        end
      end
    end
  end
end
