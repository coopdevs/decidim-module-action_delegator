# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # Returns total votes of each response by memberships' type and weight.
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
            coalesce(Ponderation.arel_table[:name], default_metadata).as("membership_type"),
            coalesce(Ponderation.arel_table[:weight], 1).as("membership_weight"),
            votes_count
          )
          .group(
            responses[:decidim_consultations_questions_id],
            responses[:title],
            sql(:membership_type),
            sql(:membership_weight)
          )
          .order(:title, :membership_type, { membership_weight: :desc }, "votes_count DESC")
      end

      private

      attr_reader :relation

      def default_metadata
        sql(ActiveRecord::Base::sanitize_sql(["?", DEFAULT_METADATA]))
      end

      def votes_count
        sql("COUNT(*)").as(sql(:votes_count))
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
