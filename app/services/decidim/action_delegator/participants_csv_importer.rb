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
          error_rows: []
        }

        ActiveRecord::Base.transaction do
          i = 1
          csv = CSV.new(@csv_file, headers: true, col_sep: ",")
          while (row = csv.shift).present?
            i += 1
            next if row.empty?

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
        @participant = Decidim::ActionDelegator::Participant.find_by(email: form.email, setting: @current_setting)

        if @participant.present?
          Decidim::ActionDelegator::Admin::UpdateParticipant.call(form, @participant) do
            on(:invalid) do
              form.errors.add(:base, I18n.t("import.csv.invalid_row"))
            end
          end
        else
          Decidim::ActionDelegator::Admin::CreateParticipant.call(form) do
            on(:invalid) do
              form.errors.add(:base, I18n.t("import.csv.invalid_row"))
            end
          end
        end
      end
    end
  end
end
