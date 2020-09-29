# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ResponsesByMembership < Rectify::Query
      def initialize(question)
        @question = question
      end

      def query
        question
          .responses
          .joins(:votes)
          .joins("INNER JOIN decidim_authorizations
                  ON decidim_authorizations.decidim_user_id = decidim_consultations_votes.decidim_author_id")
          .group(
            :title,
            "decidim_authorizations.metadata ->> 'membership_type'",
            "decidim_authorizations.metadata ->> 'membership_weight'"
          )
          .select(
            :title,
            "decidim_authorizations.metadata ->> 'membership_type' AS membership_type",
            "decidim_authorizations.metadata ->> 'membership_weight' AS membership_weight",
            "COUNT(*) AS votes_count"
          )
          .order("votes_count DESC")
      end

      private

      attr_reader :question
    end
  end
end
