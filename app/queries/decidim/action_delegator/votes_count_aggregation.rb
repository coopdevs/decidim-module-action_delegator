# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotesCountAggregation
      def initialize(field, aliaz)
        @field = field
        @aliaz = aliaz
      end

      def to_sql
        int_field = cast(field, :integer)
        int_field = coalesce(int_field, 1)
        Arel::Nodes::Sum.new([int_field], aliaz).to_sql
      end

      private

      attr_reader :field, :aliaz

      # Returns the equivalent of `CAST ((<exprs>) AS <type>)` in Arel
      def cast(*exprs, type)
        Arel::Nodes::NamedFunction.new(
          "CAST",
          [Arel::Nodes::As.new(Arel::Nodes::Grouping.new(exprs), Arel.sql(type.to_s.upcase))]
        )
      end

      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end
    end
  end
end
