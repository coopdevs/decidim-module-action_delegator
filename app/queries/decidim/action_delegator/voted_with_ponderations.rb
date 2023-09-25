# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotedWithPonderations < Decidim::Query
      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .joins(:votes)
          .joins(ponderation_sql)
      end

      private

      attr_reader :relation

      def ponderation_sql
        <<~SQL.squish
          LEFT OUTER JOIN "decidim_action_delegator_settings" ON "decidim_action_delegator_settings"."decidim_consultation_id" = "decidim_consultations_questions"."decidim_consultation_id"
          LEFT OUTER JOIN "decidim_action_delegator_participants"  ON "decidim_action_delegator_participants"."decidim_action_delegator_setting_id" = "decidim_action_delegator_settings"."id"
                                                                  AND "decidim_action_delegator_participants"."decidim_user_id" = "decidim_consultations_votes"."decidim_author_id"
          LEFT OUTER JOIN "decidim_action_delegator_ponderations"  ON "decidim_action_delegator_ponderations"."id" = "decidim_action_delegator_participants"."decidim_action_delegator_ponderation_id"
        SQL
      end
    end
  end
end
