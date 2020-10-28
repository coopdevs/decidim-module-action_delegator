# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VoteDelegation
      def initialize(form)
        @form = form
        @delegation = form.context.delegation
      end

      def call
        build_vote
      end

      private

      attr_reader :form, :delegation

      def build_vote
        form.context.current_question.votes.build(
          author: delegation.granter,
          response: form.response
        )
      end
    end
  end
end
