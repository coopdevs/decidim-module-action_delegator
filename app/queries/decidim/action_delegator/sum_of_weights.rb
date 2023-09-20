# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SumOfWeights < Decidim::Query
      def initialize(consultation)
        @consultation = consultation
      end

      def query
        SumOfMembershipWeight.new(published_questions_responses).query
      end

      private

      attr_reader :consultation

      def published_questions_responses
        VotedWithPonderations.new(
          Responses.new(consultation).query
        ).query
      end
    end
  end
end
