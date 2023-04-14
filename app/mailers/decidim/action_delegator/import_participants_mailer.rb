# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This mailer sends a notification email containing the result of importing a
    # CSV of results.
    class ImportParticipantsMailer < Decidim::ApplicationMailer
      # Public: Sends a notification email with the result of a CSV import
      # of results.
      #
      # user   - The user to be notified.
      # errors - The list of errors generated by the import
      #
      # Returns nothing.
      def import(user, import_summary, csv_file_path)
        @user = user
        @organization = user.organization
        @import_summary = import_summary
        @csv_file_path = csv_file_path

        attachments["errors.csv"] = File.read(@csv_file_path)

        with_user(user) do
          mail(to: "#{user.name} <#{user.email}>", subject: I18n.t("decidim.action_delegator.import_participants_mailer.import.subject"))
        end
      end
    end
  end
end
