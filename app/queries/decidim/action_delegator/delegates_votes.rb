# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotes < Rectify::Query
      def query
        Decidim::User
          .joins("INNER JOIN decidim_action_delegator_delegations
                    ON decidim_users.id = decidim_action_delegator_delegations.granter_id
                  INNER JOIN decidim_consultations_votes
                    ON decidim_consultations_votes.decidim_author_id = decidim_action_delegator_delegations.granter_id")
      end

      private

      attr_reader :authors_ids_votes, :relation
    end
  end
end
