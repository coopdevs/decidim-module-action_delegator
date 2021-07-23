# frozen_string_literal: true

require "json_key"

module Decidim
  module ActionDelegator
    class SumOfMembershipWeight < Rectify::Query
      def initialize(relation)
        @relation = relation
      end

      def query
        relation
          .select(
            questions[:id].as("question_id"),
            questions[:title].as("question_title"),
            responses[:title],
            votes_count
          )
          .group(
            questions[:id],
            questions[:title],
            responses[:title]
          )
          .order(responses[:title])
      end

      private

      attr_reader :relation

      def questions
        Consultations::Question.arel_table
      end

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def authorizations
        Decidim::Authorization.arel_table
      end

      def votes_count
        json_args = votes_count_by_question_id
        field = questions[:id]
        JsonBuildObjectQuery.new(json_args, field, "votes_count").to_sql
      end

      def votes_count_by_question_id
        subquery.map do |row|
          [
            row.question_id,
            row.encrypted_membership_weight_agg.reduce(0) do |sum, membership_weight|
              num = membership_weight.nil? ? 1 : decrypt_value(membership_weight).to_i

              sum + num
            end
          ]
        end
      end

      def subquery
        relation
          .select(
            questions[:id].as("question_id"),
            encrypted_membership_weight_agg
          )
          .group(
            questions[:id],
            responses[:id]
          )
      end

      def encrypted_membership_weight_agg
        Arel::Nodes::NamedFunction.new(
          "ARRAY_AGG",
          [metadata("membership_weight")],
          "encrypted_membership_weight_agg"
        ).to_sql
      end

      def metadata(name)
        JSONKey.new(authorizations[:metadata], name)
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
