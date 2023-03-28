# frozen_string_literal: true

require "securerandom"

module Decidim
  module ActionDelegator
    module Verifications
      # A form object to be used when public users want to get verified using their phone.
      class DelegationsVerifierForm < AuthorizationHandler
        attribute :email, String
        attribute :phone, String

        validates :phone, :verification_code, :sms_gateway, presence: true
        validate :setting_exists

        def handler_name
          "delegations_verifier"
        end

        # A mobile phone can only be verified once but it should be private.
        def unique_id
          Digest::MD5.hexdigest(
            "#{phone}-#{Rails.application.secrets.secret_key_base}"
          )
        end

        # email is predefined always
        def email
          current_user.email
        end

        # When there's a phone number, sanitize it allowing only numbers and +.
        def phone
          return find_phone if setting&.phone_freezed?
          return unless super

          super.gsub(/[^+0-9]/, "")
        end

        # The verification metadata to validate in the next step.
        def verification_metadata
          {
            verification_code: verification_code,
            code_sent_at: Time.current
          }
        end

        # currently, we rely on the last setting.
        # This could be improved by allowing the user to select the setting (or related phone).
        def setting
          @setting ||= context[:setting]
        end

        def participants
          @participants ||= context[:participants]
        end

        private

        def setting_exists
          return if errors.any?
          # return if setting

          errors.add(:base, :invalid)
        end

        def verification_code
          return unless sms_gateway
          return @verification_code if defined?(@verification_code)

          return unless sms_gateway.new(phone, generated_code).deliver_code

          @verification_code = generated_code
        end

        def sms_gateway
          (Decidim.sms_gateway_service || ActionDelegator.sms_gateway_service).to_s.safe_constantize
        end

        def generated_code
          @generated_code ||= SecureRandom.random_number(1_000_000).to_s
        end

        def find_phone
          @find_phone ||= participants.find_by(email: current_user.email)&.phone
        end
      end
    end
  end
end
