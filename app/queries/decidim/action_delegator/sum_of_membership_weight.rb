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
            responses[:decidim_consultations_questions_id],
            responses[:title],
            votes_count
          )
          .group(
            responses[:decidim_consultations_questions_id],
            responses[:title]
          )
          .order(:title)
      end

      private

      attr_reader :relation

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def authorizations
        Decidim::Authorization.arel_table
      end

      def votes_count
        field = metadata("membership_weight")
        VotesCountAggregation.new(field, "votes_count").to_sql
      end

      def metadata(name)
        JSONKey.new(authorizations[:metadata], name)
      end
    end
  end
end
