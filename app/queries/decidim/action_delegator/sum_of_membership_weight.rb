# frozen_string_literal: true

require "json_key"

module Decidim
  module ActionDelegator
    class SumOfMembershipWeight < Rectify::Query
      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .select(
            questions[:id].as("question_id"),
            questions[:title].as("question_title"),
            responses[:title],
            votes_count
          )
          .group(
            questions[:id],
            questions[:title],
            responses[:title]
          )
          .order(responses[:title])
      end

      private

      attr_reader :relation

      def questions
        Consultations::Question.arel_table
      end

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def votes_count
        VotesCountAggregation.new(relation, "votes_count").to_sql
      end
    end
  end
end
