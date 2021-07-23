# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class VotesCountAggregation
      def initialize(relation, aliaz)
        @relation = relation
        @aliaz = aliaz
      end

      def to_sql
        <<-SQL
          JSON_BUILD_OBJECT(#{votes_count_by_question_id.flatten.join(", ")}) ->> (decidim_consultations_questions.id :: TEXT) AS #{aliaz}
        SQL
      end

      private

      attr_reader :relation, :aliaz

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
