# frozen_string_literal: true

require "json_key"

module Decidim
  module ActionDelegator
    class DecryptedAuthorizations < Rectify::Query
      METADATA_FIELDS = %w(
        membership_type
        membership_weight
      ).freeze

      def initialize(relation)
        @relation = relation
      end

      def query
        authorizations
          .project(
            authorizations[:id],
            authorizations[:name],
            authorizations[:decidim_user_id],
            *decrypted_authorizations_metadata_fields
          )
          .where(authorizations[:id].in(authorization_ids))
      end

      private

      attr_reader :relation

      def authorizations
        Decidim::Authorization.arel_table
      end

      def decrypted_authorizations_metadata_fields
        METADATA_FIELDS.map do |field|
          decrypted_authorizations_metadata_field(field)
        end
      end

      def decrypted_authorizations_metadata_field(field)
        JsonBuildObjectQuery.new(
          metadata_field_by_authorization_id(field).flatten,
          authorizations[:id],
          field
        ).to_sql
      end

      def metadata_field_by_authorization_id(field)
        decrypted_authorizations.map do |hash|
          [
            hash.fetch("id"),
            hash.fetch(field)
          ]
        end
      end

      def decrypted_authorizations
        @decrypted_authorizations ||=
          sql_query_results(encrypted_authorizations).map do |hash|
            hash.transform_values! do |value|
              if value.nil?
                Arel.sql("NULL")
              else
                value.is_a?(String) ? decrypt_and_parse(value) : value
              end
            end
          end
      end

      def sql_query_results(sql)
        ActiveRecord::Base.connection.exec_query(sql).to_a
      end

      def encrypted_authorizations
        Decidim::Authorization
          .select(
            :id,
            *authorizations_metadata_fields
          )
          .where(id: authorization_ids)
          .to_sql
      end

      def authorizations_metadata_fields
        METADATA_FIELDS.map do |field|
          authorizations_metadata_field(field).as(field)
        end
      end

      def authorizations_metadata_field(field)
        JSONKey.new(authorizations[:metadata], field)
      end

      def authorization_ids
        @authorization_ids ||= relation.pluck("decidim_authorizations.id").compact
      end

      def decrypt_and_parse(value)
        Arel.sql("'#{JSON.parse(decrypt_value(value))}'")
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
