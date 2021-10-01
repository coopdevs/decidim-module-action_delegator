# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotedWithDirectVerification < Rectify::Query
      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .joins(:votes)
          .joins(join_on_votes_author(decrypted_authorizations))
          .where(direct_verification.or(no_authorization))
      end

      private

      attr_reader :relation

      def join_on_votes_author(arel_table)
        join_on = votes.create_on(arel_table[:decidim_user_id].eq(votes[:decidim_author_id]))
        arel_table.create_join(arel_table, join_on, Arel::Nodes::OuterJoin)
      end

      def votes
        Decidim::Consultations::Vote.arel_table
      end

      def decrypted_authorizations
        @decrypted_authorizations ||= DecryptedAuthorizations.new(subquery).query.as("decrypted_authorizations")
      end

      def subquery
        relation
          .joins(:votes)
          .joins(join_on_votes_author(authorizations))
      end

      def authorizations
        Decidim::Authorization.arel_table
      end

      def direct_verification
        decrypted_authorizations[:name].eq("direct_verifications")
      end

      def no_authorization
        decrypted_authorizations[:id].eq(nil)
      end
    end
  end
end
