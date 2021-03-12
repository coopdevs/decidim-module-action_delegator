# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SumOfMembershipWeight < Rectify::Query
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
            votes_count
          )
          .where(direct_verification.or(no_authorization))
          .group(
            responses[:decidim_consultations_questions_id],
            responses[:title]
          )
          .order(:title)
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

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def sql(name)
        Arel.sql(name.to_s)
      end

      def default_metadata
        Arel.sql("'#{DEFAULT_METADATA}'")
      end

      def count_star
        sql("COUNT(*)")
      end

      def direct_verification
        authorizations[:name].eq("direct_verifications")
      end

      def no_authorization
        authorizations[:id].eq(nil)
      end

      def votes_count
        # "4 AS votes_count"
        # coalesce(membership_weight, 1).as(sql(:votes_count))
        "SUM(COALESCE(#{membership_weight}, 1)) AS votes_count"
      end

      def membership_weight
        field = metadata("membership_weight")
        "CAST((#{field.to_sql}) AS INTEGER)"
      end

      def metadata(name)
        Arel::Nodes::InfixOperation.new("->>", authorizations[:metadata], sql("'#{name}'"))
      end

      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end

      def cast(expr, type)
        Arel::Nodes::NamedFunction.new("CAST", "#{expr.to_sql} AS #{type.upcase}")
      end

      def as(left, right)
        Arel::Nodes::As.new(left, right)
      end
    end
  end
end
