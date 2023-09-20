# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class TypeAndWeight < Decidim::Query
      def initialize(consultation)
        @consultation = consultation
      end

      def query
        relation = VotedWithPonderations.new(published_questions_responses).query
        ResponsesByMembership.new(relation).query
      end

      private

      attr_reader :consultation

      # Returns the published questions' responses of the given consultation as an ActiveRecord
      # Relation. Note this enables us to the chain it with other AR Relation objects.
      def published_questions_responses
        Responses.new(consultation).query
      end
    end
  end
end
