# frozen_string_literal: true

require "json_key"

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
            votes[:id],
            responses[:id],
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
        json_args = membership_field_by_question_id(full_field)
        field = votes[:id]
        JsonBuildObjectQuery.new(json_args, field, full_field).to_sql
      end

      def membership_field_by_question_id(membership_field)
        subquery.map do |row|
          [
            row.vote_id,
            row.send(membership_field).nil? ? default_metadata : sql("'#{JSON.parse(decrypt_value(row.send(membership_field)))}'")
          ]
        end
      end

      def subquery
        @subquery ||=
          relation
          .select(
            responses[:decidim_consultations_questions_id],
            votes[:id].as("vote_id"),
            metadata(:membership_type).as("membership_type"),
            metadata(:membership_weight).as("membership_weight")
          )
          .group(
            votes[:id],
            responses[:id],
            responses[:decidim_consultations_questions_id],
            metadata(:membership_type),
            metadata(:membership_weight)
          )
      end

      def default_metadata
        sql("'#{DEFAULT_METADATA}'")
      end

      def votes_count
        sql("COUNT(*)").as(sql(:votes_count))
      end

      def metadata(name)
        JSONKey.new(authorizations[:metadata], name)
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

      # This method comes with Rails 6. See:
      # https://github.com/rails/rails/commit/e5190acacd1088211cfe6f128b782af216aa6570
      def coalesce(*exprs)
        Arel::Nodes::NamedFunction.new("COALESCE", exprs)
      end

      def decrypt_value(value)
        Decidim::AttributeEncryptor.decrypt(value)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        # Support for legacy unencrypted values.
        value
      end
    end
  end
end
