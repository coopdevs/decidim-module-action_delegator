# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SumOfMembershipWeight < Rectify::Query
      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .select(
            responses[:decidim_consultations_questions_id],
            responses[:title],
            votes_count
          )
          .group(
            responses[:decidim_consultations_questions_id],
            responses[:title]
          )
          .order(:title)
      end

      private

      attr_reader :relation

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def sql(name)
        Arel.sql(name.to_s)
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

      def authorizations
        Decidim::Authorization.arel_table
      end

      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end

      def cast(*exprs)
        Arel::Nodes::UnaryOperation.new("::INTEGER", responses[:id]).to_sql
      end

      def as(left, right)
        Arel::Nodes::As.new(left, right)
      end
    end
  end
end
