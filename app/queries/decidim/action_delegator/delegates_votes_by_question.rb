# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByQuestion < Rectify::Query
      def initialize(question)
        @authors_ids_votes = question.votes.pluck(:decidim_author_id)
      end

      def query
        Decidim::User
          .joins("INNER JOIN decidim_action_delegator_delegations
                    ON decidim_users.id = decidim_action_delegator_delegations.granter_id
                  INNER JOIN decidim_consultations_votes
                    ON decidim_consultations_votes.decidim_author_id = decidim_action_delegator_delegations.granter_id")
          .where(decidim_action_delegator_delegations: { granter_id: @authors_ids_votes }).distinct.count
      end
    end
  end
end
