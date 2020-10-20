# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SmsGateway
      attr_reader :mobile_phone_number, :code, :response

      def initialize(mobile_phone_number, code)
        @mobile_phone_number = mobile_phone_number
        @code = code
      end

      def deliver_code
        SendSmsJob.perform_later(sender_name, mobile_phone_number, message)

        true
      end

      private

      def sender_name
        ENV["SMS_SENDER_NAME"] || Decidim.application_name
      end

      def message
        I18n.t("decidim.action_delegator.sms_message", code: code)
      end
    end
  end
end
