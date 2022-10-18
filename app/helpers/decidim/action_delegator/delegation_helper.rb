# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module DelegationHelper
      def has_any_delegate_vote?(question)
        any_delegate_vote = false

        Decidim::ActionDelegator::GranteeDelegations.for(question.consultation, current_user).each do |delegation|
          any_delegate_vote = true if question.voted_by?(delegation.granter)
        end

        any_delegate_vote
      end
    end
  end
end
