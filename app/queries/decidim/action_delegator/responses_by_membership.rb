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

      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .select(
            responses[:decidim_consultations_questions_id],
            responses[:title],
            membership(:type),
            membership(:weight),
            votes_count
          )
          .group(
            responses[:decidim_consultations_questions_id],
            responses[:title],
            metadata(:membership_type),
            metadata(:membership_weight)
          )
          .order(:title, :membership_type, { membership_weight: :desc }, "votes_count DESC")
      end

      private

      attr_reader :relation

      def membership(field)
        full_field = "membership_#{field}"
        coalesce(metadata(full_field), default_metadata).as(full_field)
      end

      def default_metadata
        sql("'#{DEFAULT_METADATA}'")
      end

      def votes_count
        sql("COUNT(*)").as(sql(:votes_count))
      end

      # Retuns the value of the specified key in the `metadata` JSONB PostgreSQL column. More
      # details: https://www.postgresql.org/docs/current/functions-json.html
      def metadata(name)
        Arel::Nodes::InfixOperation.new("->>", authorizations[:metadata], sql("'#{name}'"))
      end

      def authorizations
        Decidim::Authorization.arel_table
      end

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def sql(name)
        Arel.sql(name.to_s)
      end

      # This method comes with Rails 6. See:
      # https://github.com/rails/rails/commit/e5190acacd1088211cfe6f128b782af216aa6570
      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end
    end
  end
end
