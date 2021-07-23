# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotesCountAggregation
      def initialize(votes_count_by_field, field, aliaz)
        @votes_count_by_field = votes_count_by_field
        @field = field
        @aliaz = aliaz
      end

      def to_sql
        Arel::Nodes::InfixOperation.new(
          "->>",
          json_build_object(votes_count_by_field.to_a.flatten),
          cast(field, :text)
        ).as(aliaz).to_sql
      end

      private

      attr_reader :votes_count_by_field, :field, :aliaz

      # Returns the equivalent of `JSON_BUILD_OBJECT (ARRAY)` in Arel
      def json_build_object(array)
        Arel::Nodes::NamedFunction.new(
          "JSON_BUILD_OBJECT",
          [array]
        )
      end

      # Returns the equivalent of `CAST ((<exprs>) AS <type>)` in Arel
      def cast(*exprs, type)
        Arel::Nodes::NamedFunction.new(
          "CAST",
          [Arel::Nodes::As.new(Arel::Nodes::Grouping.new(exprs), Arel.sql(type.to_s.upcase))]
        )
      end
    end
  end
end
