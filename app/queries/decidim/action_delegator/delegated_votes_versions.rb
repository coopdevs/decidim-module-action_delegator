# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # Returns all PaperTrail versions of a consultation's delegated votes for auditing purposes.
    # It is intended to be used to easily fetch this data when a judge ask us so.
    class DelegatedVotesVersions
      def initialize(consultation)
        @consultation = consultation
      end

      def query
        statement = <<-SQL.strip_heredoc
          SELECT *
          FROM versions
          INNER JOIN decidim_action_delegator_delegations
            ON decidim_action_delegator_delegations.id = versions.decidim_action_delegator_delegation_id
          INNER JOIN decidim_action_delegator_settings
            ON decidim_action_delegator_settings.id = decidim_action_delegator_delegations.decidim_action_delegator_setting_id
          WHERE decidim_action_delegator_settings.decidim_consultation_id = #{consultation.id}
        SQL

        ActiveRecord::Base.connection.execute(statement).to_a
      end

      private

      attr_reader :consultation
    end
  end
end
