# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ParticipantsCsvImporter
      include Decidim::FormFactory

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

        ActiveRecord::Base.transaction do
          i = 1
          csv = CSV.new(@csv_file, headers: true, col_sep: ",")

          CSV.open(details_csv_file, "wb") do |details_csv|
            headers(csv, details_csv)

            csv.rewind

            while (row = csv.shift).present?
              i += 1

              params = extract_params(row)
              weight = ponderation_value(row["weight"].strip) if row["weight"].present?

              @form = form(Decidim::ActionDelegator::Admin::ParticipantForm).from_params(params, setting: @current_setting)

              next if row&.empty?

              if participant_exists?(@form)
                mismatch_fields = mismatched_fields(@form)
                info_message = generate_info_message(mismatch_fields)
                handle_skipped_row(row, details_csv, import_summary, i, info_message)

                next
              end

              if phone_exists?(@form)
                reason = I18n.t("phone_exists", scope: "decidim.action_delegator.participants_csv_importer.import")
                handle_skipped_row(row, details_csv, import_summary, i, reason)

                next
              end

              if find_ponderation(weight).nil?
                reason = I18n.t("ponderation_not_found", scope: "decidim.action_delegator.participants_csv_importer.import")
                handle_skipped_row(row, details_csv, import_summary, i, reason)

                next
              end

              if @form.valid?
                process_participant(@form)
                import_summary[:imported_rows] += 1
              else
                handle_import_error(row, details_csv, import_summary, i, @form.errors.full_messages)
              end
            end
          end
          import_summary[:total_rows] = i - 1
          import_summary[:details_csv_path] = details_csv_file
        end

        import_summary
      end

      private

      def authorization_method
        @current_setting.authorization_method
      end

      def extract_params(row)
        email, phone, weight = extract_contact_details(row, authorization_method)
        weight = ponderation_value(row["weight"].strip) if row["weight"].present?

        params = {
          email: email,
          phone: phone,
          weight: weight,
          decidim_action_delegator_ponderation_id: find_ponderation(weight)&.id
        }

        @form = form(Decidim::ActionDelegator::Admin::ParticipantForm).from_params(params, setting: @current_setting)

        params
      end

      def extract_contact_details(row, authorization_method)
        email = row["email"].to_s.strip
        phone = row["phone"].to_s.strip

        email = nil if %w(email both).include?(authorization_method.to_s) && invalid_email?(email)

        phone = nil if %w(phone both).include?(authorization_method.to_s) && invalid_phone?(phone)

        [email, phone]
      end

      def invalid_email?(email)
        email.blank? || !email.match?(::Devise.email_regexp)
      end

      def invalid_phone?(phone)
        phone.blank? || !phone.gsub(/[^+0-9]/, "").match?(Decidim::ActionDelegator.phone_regex)
      end

      def process_participant(form)
        assign_ponderation(form.weight) if find_ponderation(form.weight).present?
        create_new_participant(form)
      end

      def participant_exists?(form)
        check_exists?(:email, form)
      end

      def phone_exists?(form)
        check_exists?(:phone, form)
      end

      def check_exists?(field, form)
        @participant = Decidim::ActionDelegator::Participant.find_by(field => form.send(field), setting: @current_setting)
        @participant.present?
      end

      def handle_skipped_row(row, details_csv, import_summary, row_number, reason)
        import_summary[:skipped_rows] << { row_number: row_number - 1 }
        row["reason"] = reason
        details_csv << row
      end

      def handle_import_error(row, details_csv, import_summary, row_number, error_messages)
        import_summary[:error_rows] << { row_number: row_number - 1, error_messages: error_messages }
        row["reason"] = reason
        details_csv << row
      end

      def mismatched_fields(form)
        mismatch_fields = []
        mismatch_fields << I18n.t("decidim.action_delegator.participants_csv_importer.import.field_name.phone") if form.phone != @participant.phone

        if form.decidim_action_delegator_ponderation_id != @participant.decidim_action_delegator_ponderation_id
          mismatch_fields << I18n.t("decidim.action_delegator.participants_csv_importer.import.field_name.weight")
        end

        mismatch_fields.empty? ? nil : mismatch_fields.join(", ")
      end

      def generate_info_message(mismatch_fields)
        with_mismatched_fields = mismatch_fields.present? ? I18n.t("decidim.action_delegator.participants_csv_importer.import.with_mismatched_fields", fields: mismatch_fields) : ""
        I18n.t("decidim.action_delegator.participants_csv_importer.import.skip_import_info", with_mismatched_fields: with_mismatched_fields)
      end

      def update_existing_participant(form)
        Decidim::ActionDelegator::Admin::UpdateParticipant.call(form, @participant) do
          on(:invalid) do
            flash.now[:error] = I18n.t("participants.update.error", scope: "decidim.action_delegator.admin")
          end
        end
      end

      def create_new_participant(form)
        Decidim::ActionDelegator::Admin::CreateParticipant.call(form) do
          on(:invalid) do
            flash.now[:error] = I18n.t("participants.create.error", scope: "decidim.action_delegator.admin")
          end
        end
      end

      def assign_ponderation(weight)
        ponderation = find_ponderation(weight)
        @form.decidim_action_delegator_ponderation_id = ponderation.id
      end

      def find_ponderation(weight)
        case weight
        when String
          @current_setting.ponderations.find_by(name: weight).presence
        when Numeric
          ponderation = @current_setting.ponderations.find_by(weight: weight)
          ponderation.presence || @current_setting.ponderations.create(name: "weight-#{weight}", weight: weight)
        end
      end

      def ponderation_value(value)
        Float(value)
      rescue StandardError
        value
      end

      def headers(csv, details_csv)
        headers = csv.first.headers
        headers << I18n.t("decidim.action_delegator.participants_csv_importer.import.error_field")
        details_csv << headers
      end
    end
  end
end
