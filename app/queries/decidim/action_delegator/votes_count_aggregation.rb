# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotesCountAggregation
      def initialize(relation, aliaz)
        @relation = relation
        @aliaz = aliaz
      end

      def to_sql
        Arel::Nodes::InfixOperation.new(
          "->>",
          json_build_object(votes_count_by_question_id.flatten),
          cast(questions[:id], :text)
        ).as(aliaz).to_sql
      end

      private

      attr_reader :relation, :aliaz

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

      def votes_count_by_question_id
        query.map do |row|
          [
            row.question_id,
            row.encrypted_membership_weight_agg.reduce(0) do |sum, membership_weight|
              num = membership_weight.nil? ? 1 : decrypt_value(membership_weight).to_i

              sum + num
            end
          ]
        end
      end

      def query
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

      def questions
        Consultations::Question.arel_table
      end

      def responses
        Decidim::Consultations::Response.arel_table
      end

      def encrypted_membership_weight_agg
        Arel::Nodes::NamedFunction.new(
          "ARRAY_AGG",
          [authorizations_metadata("membership_weight")],
          "encrypted_membership_weight_agg"
        ).to_sql
      end

      def authorizations_metadata(name)
        JSONKey.new(authorizations[:metadata], name)
      end

      def authorizations
        Decidim::Authorization.arel_table
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
