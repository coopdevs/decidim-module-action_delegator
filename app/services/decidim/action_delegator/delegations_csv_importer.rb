# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegationsCsvImporter < CsvImporter
      def process(row, params, details_csv, import_summary, iterator)
        if delegation_exists?(params)
          message = generate_info_message(row)

          handle_skipped_row(row, details_csv, import_summary, iterator, message)

          false
        else
          true
        end
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

      def handle_form_validity(row, details_csv, import_summary, row_number)
        if @form.valid?
          process_delegation(@form)
          import_summary[:imported_rows] += 1
        else
          handle_import_error(row, details_csv, import_summary, row_number, @form.errors.full_messages.join(", "))
        end
      end
    end
  end
end
