# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotedResponses < Rectify::Query
      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .joins(:votes)
          .joins(authorizations_on_author)
          .where(direct_verification.or(no_authorization))
      end

      private

      attr_reader :relation

      def authorizations_on_author
        join_on = votes.create_on(authorizations[:decidim_user_id].eq(votes[:decidim_author_id]))
        authorizations.create_join(authorizations, join_on, Arel::Nodes::OuterJoin)
      end

      def votes
        Decidim::Consultations::Vote.arel_table
      end

      def authorizations
        Decidim::Authorization.arel_table
      end

      def direct_verification
        authorizations[:name].eq("direct_verifications")
      end

      def no_authorization
        authorizations[:id].eq(nil)
      end
    end
  end
end
