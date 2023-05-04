# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegationsCsvImporter < CsvImporter
      def initialize(csv_file, current_user, current_setting)
        @csv_file = csv_file
        @current_user = current_user
        @current_setting = current_setting
      end

      def import!
        import_summary = {
          total_rows: 0,
          imported_rows: 0,
          error_rows: [],
          skipped_rows: [],
          details_csv_path: nil
        }

        details_csv_file = File.join(File.dirname(@csv_file), "details.csv")

        i = 1
        csv = CSV.new(@csv_file, headers: true, col_sep: ",")

        CSV.open(details_csv_file, "wb") do |details_csv|
          headers(csv, details_csv)

          csv.rewind

          while (row = csv.shift).present?
            i += 1

            params = extract_params(row)

            @form = form(Decidim::ActionDelegator::Admin::DelegationForm).from_params(params, setting: @current_setting)

            next if row&.empty?

            if delegation_exists?(params)
              info_message = generate_info_message(row)

              handle_skipped_row(row, details_csv, import_summary, i, info_message)

              next
            end

            handle_form_validity(row, details_csv, import_summary, i)
          end
        end
        import_summary[:total_rows] = i - 1
        import_summary[:details_csv_path] = details_csv_file

        import_summary
      end

      private

      def extract_params(row)
        granter, grantee = extract_details(row)

        params = {
          granter_id: granter,
          grantee_id: grantee
        }

        @form = form(Decidim::ActionDelegator::Admin::DelegationForm).from_params(params, setting: @current_setting)

        params
      end

      def extract_details(row)
        granter_email = row["granter_email"].to_s.strip.downcase
        grantee_email = row["grantee_email"].to_s.strip.downcase

        granter = user_id(granter_email)
        grantee = user_id(grantee_email)

        granter = nil if invalid_email?(granter_email) && granter.nil?
        grantee = nil if invalid_email?(grantee_email) && grantee.nil?

        [granter, grantee]
      end

      def user_id(email)
        Decidim::User.find_by(email: email)&.id
      end

      def process_delegation(form)
        create_new_delegation(form)
      end

      def delegation_exists?(params)
        @delegation = Delegation.find_by(granter_id: params[:granter_id], grantee_id: params[:grantee_id])

        @delegation.present?
      end

      def create_new_delegation(form)
        Decidim::ActionDelegator::Admin::CreateDelegation.call(form, @current_user, @current_setting)
      end
    end
  end
end
