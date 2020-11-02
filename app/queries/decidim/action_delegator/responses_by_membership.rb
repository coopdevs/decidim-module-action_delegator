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
      DEFAULT_METADATA = I18n.t("decidim.admin.consultations.results.default_metadata")

      def initialize(relation = nil)
        @relation = relation.presence || Decidim::Consultations::Response
      end

      def query
        relation
          .joins(:votes)
          .joins(authorizations_on_author)
          .select(
            responses[:decidim_consultations_questions_id],
            responses[:title],
            membership(:type),
            membership(:weight),
            count_star.as(sql(:votes_count))
          )
          .where(direct_verification.or(no_authorization))
          .group(
            responses[:decidim_consultations_questions_id],
            responses[:title],
            metadata(:membership_type),
            metadata(:membership_weight)
          )
          .order(:title, :membership_type, { membership_weight: :desc }, votes_count)
      end

      private

      attr_reader :relation

      def membership(field)
        full_field = "membership_#{field}"
        coalesce(metadata(full_field), default_metadata).as(full_field)
      end

      def default_metadata
        Arel.sql("'#{DEFAULT_METADATA}'")
      end

      def authorizations_on_author
        join_on = votes.create_on(authorizations[:decidim_user_id].eq(votes[:decidim_author_id]))
        authorizations.create_join(authorizations, join_on, Arel::Nodes::OuterJoin)
      end

      def votes_count
        "votes_count DESC"
      end

      def count_star
        sql("COUNT(*)")
      end

      # Retuns the value of the specified key in the `metadata` JSONB PostgreSQL column. More
      # details: https://www.postgresql.org/docs/current/functions-json.html
      def metadata(name)
        Arel::Nodes::InfixOperation.new("->>", authorizations[:metadata], sql("'#{name}'"))
      end

      def direct_verification
        authorizations[:name].eq("direct_verifications")
      end

      def no_authorization
        authorizations[:id].eq(nil)
      end

      def authorizations
        Decidim::Authorization.arel_table
      end

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def votes
        Decidim::Consultations::Vote.arel_table
      end

      def sql(name)
        Arel.sql(name.to_s)
      end

      def as(left, right)
        Arel::Nodes::As.new(left, right)
      end

      # This method comes with Rails 6. See:
      # https://github.com/rails/rails/commit/e5190acacd1088211cfe6f128b782af216aa6570
      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end
    end
  end
end
