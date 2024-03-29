# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This query object replaces the ActiveRecord association we would have between the Vote and
    # Delegation models. Unfortunately we can't use custom foreign keys on both ends of the
    # association so this aims to replace `delegation.votes`.
    class DelegationVotes < Decidim::Query
      def query
        Delegation.joins(
          delegations.join(votes).on(vote_author_eq_granter).join_sources
        )
      end

      private

      def votes
        Decidim::Consultations::Vote.arel_table
      end

      def delegations
        Delegation.arel_table
      end

      def vote_author_eq_granter
        votes[:decidim_author_id].eq(delegations[:granter_id])
      end
    end
  end
end
