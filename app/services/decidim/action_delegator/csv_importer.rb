# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class CsvImporter
      include Decidim::FormFactory

      def handle_skipped_row(row, details_csv, import_summary, row_number, reason)
        import_summary[:skipped_rows] << { row_number: row_number - 1 }
        row["reason"] = reason
        details_csv << row
      end

      def handle_import_error(row, details_csv, import_summary, row_number, error_messages)
        import_summary[:error_rows] << { row_number: row_number - 1, error_messages: error_messages }
        row["reason"] = error_messages
        details_csv << row
      end

      def handle_form_validity(row, details_csv, import_summary, row_number)
        if @form.valid?
          process_delegation(@form)
          import_summary[:imported_rows] += 1
        else
          handle_import_error(row, details_csv, import_summary, row_number, @form.errors.full_messages.join(", "))
        end
      end

      def generate_info_message(mismatch_fields)
        with_mismatched_fields = mismatch_fields.present? ? I18n.t("decidim.action_delegator.participants_csv_importer.import.with_mismatched_fields", fields: mismatch_fields) : ""
        I18n.t("decidim.action_delegator.participants_csv_importer.import.skip_import_info", with_mismatched_fields: with_mismatched_fields)
      end

      def headers(csv, details_csv)
        headers = csv.first.headers
        headers << I18n.t("decidim.action_delegator.participants_csv_importer.import.error_field")
        details_csv << headers
      end
    end
  end
end
