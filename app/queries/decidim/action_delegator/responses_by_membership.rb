# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # Returns total votes of each response by memberships' type and weight.
    #
    # This query completely relies on the schema of the `metadata` of the relevant
    # `decidim_authorizations` records, which is expected to be like:
    #
    #   "{ membership_type: '',   membership_weight: '' }"
    #
    # Note that although we assume `membership_type` to be a string and `membership_weight` to be an
    # integer, there are no implications in the code for their actual data types.
    class ResponsesByMembership < Rectify::Query
      def initialize(relation = nil)
        @relation = relation.presence || Decidim::Consultations::Response
      end

      def query
        relation
          .joins(:votes)
          .joins(authorizations)
          .group(
            :decidim_consultations_questions_id,
            "decidim_consultations_responses.title",
            metadata_field(:membership_type),
            metadata_field(:membership_weight)
          )
          .select(
            :decidim_consultations_questions_id,
            "decidim_consultations_responses.title",
            metadata_field_with_alias(:membership_type),
            metadata_field_with_alias(:membership_weight),
            "COUNT(*) AS votes_count"
          )
          .where(decidim_authorizations: { name: "direct_verifications" })
          .order(:title, :membership_type, membership_weight: :desc)
          .order("votes_count DESC")
      end

      private

      attr_reader :relation

      def authorizations
        <<-SQL.strip_heredoc
          INNER JOIN decidim_authorizations
          ON decidim_authorizations.decidim_user_id = decidim_consultations_votes.decidim_author_id
        SQL
      end

      # Retuns the value of the specified key in the `metadata` JSONB PostgreSQL column. More
      # details: https://www.postgresql.org/docs/current/functions-json.html
      def metadata_field(name)
        "decidim_authorizations.metadata ->> '#{name}'"
      end

      def metadata_field_with_alias(name)
        "#{metadata_field(name)} AS #{name}"
      end
    end
  end
end
