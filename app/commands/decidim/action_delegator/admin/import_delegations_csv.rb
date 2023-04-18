# frozen_string_literal: true

require "csv"

module Decidim
  module ActionDelegator
    module Admin
      class ImportDelegationsCsv < Rectify::Command
        # Public: Initializes the command.
        #
        # form - the form object containing the uploaded file
        # current_user - the user performing the action
        def initialize(form, current_user, current_setting)
          @form = form
          @current_user = current_user
          @current_setting = current_setting
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @form.valid?

          process_csv
          broadcast(:ok)
        end

        private

        def process_csv
          CSV.foreach(@form.file.path, encoding: "UTF-8") do |granter_email, grantee_email|
            ImportDelegationsCsvJob.perform_later(granter_email, grantee_email, @current_user, @current_setting) if granter_email.present? && grantee_email.present?
          end
        end
      end
    end
  end
end
