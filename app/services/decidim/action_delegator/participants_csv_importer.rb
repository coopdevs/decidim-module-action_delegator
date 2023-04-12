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
          skipped_rows: []
        }

        ActiveRecord::Base.transaction do
          i = 1
          csv = CSV.new(@csv_file, headers: true, col_sep: ",")

          while (row = csv.shift).present?
            i += 1
            authorization_method = @current_setting.authorization_method

            email, phone = extract_contact_details(row, authorization_method)
            weight = row["weight"].to_s.strip

            params = {
              email: email,
              phone: phone,
              weight: weight,
              decidim_action_delegator_ponderation_id: nil
            }

            @form = form(Decidim::ActionDelegator::Admin::ParticipantForm).from_params(params, setting: @current_setting)

            next if row.empty?

            if participant_exists?(@form)
              mismatch_fields = mismatched_fields(@form)
              info_message = generate_info_message(mismatch_fields)
              import_summary[:skipped_rows] << { row_number: i - 1, error_messages: [info_message] }

              next
            end

            if @form.valid?
              process_participant(@form)
              import_summary[:imported_rows] += 1
            else
              import_summary[:error_rows] << { row_number: i - 1, error_messages: @form.errors.full_messages }
            end
          end

          import_summary[:total_rows] = i - 1
        end

        import_summary
      end

      private

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
        create_new_participant(form)
        assign_ponderation(form.weight)
      end

      def participant_exists?(form)
        @participant = Decidim::ActionDelegator::Participant.find_by(email: form.email, setting: @current_setting)

        return false if @participant.blank?

        true
      end

      def mismatched_fields(form)
        mismatch_fields = []
        mismatch_fields << I18n.t("decidim.action_delegator.participants_csv_importer.import.field_name.phone") if form.phone != @participant.phone
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
        form.decidim_action_delegator_ponderation_id = ponderation.id if ponderation.present?
      end

      def find_ponderation(weight)
        case weight
        when String
          @current_setting.ponderations.find_by(name: weight)
        when Numeric
          ponderation = @current_setting.ponderations.find_by(value: weight)
          ponderation.presence || @current_setting.ponderations.create(name: "weight-#{weight}", value: weight)
        end
      end
    end
  end
end
