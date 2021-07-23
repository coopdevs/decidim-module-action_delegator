# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class JsonBuildObjectQuery
      def initialize(json_args, field, aliaz)
        @json_args = json_args
        @field = field
        @aliaz = aliaz
      end

      def to_sql
        Arel::Nodes::InfixOperation.new(
          "->>",
          json_build_object(json_args.to_a.flatten),
          cast(field, :text)
        ).as(aliaz).to_sql
      end

      private

      attr_reader :json_args, :field, :aliaz

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

      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end
    end
  end
end
