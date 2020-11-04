# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VoteDelegation
      def initialize(form)
        @context = form.context
        @response = form.response
      end

      def call
        PaperTrail.request.controller_info = { decidim_action_delegator_delegation_id: context.delegation.id }
        WhodunnitVote.new(build_vote, context.current_user)
      end

      private

      attr_reader :context, :response

      def build_vote
        context.current_question.votes.build(
          author: context.delegation.granter,
          response: response
        )
      end
    end
  end
end
