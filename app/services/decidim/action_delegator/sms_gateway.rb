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
        send_sms!

        success?
      end

      private

      def success?
        parsed_response[:code] == "200"
      end

      def parsed_response
        return @parsed_response if @parsed_response

        doc = Nokogiri::XML response.body[:send_sms_response][:result]

        @parsed_response = {
          code: doc.xpath("//codigo").text,
          description: doc.xpath("//descripcion").text
        }

        @parsed_response
      end

      def send_sms!
        @response = client.call(:send_sms,
                                message: {
                                  user: ENV["SMS_USER"],
                                  pass: ENV["SMS_PASS"],
                                  src: sender_name,
                                  dst: mobile_phone_number,
                                  msg: message
                                })

        Rails.logger.debug "==========="
        Rails.logger.debug ["action_delegator_gateway", "send_sms!", response].map(&:inspect).join("\n")
        Rails.logger.debug "==========="
      end

      def sender_name
        ENV["SMS_SENDER_NAME"] || "Decidim"
      end

      def client
        @client ||= ::Savon.client(wsdl: "https://websms.masmovil.com/api_php/smsvirtual.wsdl")
      end

      def message
        I18n.t("decidim.action_delegator.sms_message", code: code)
      end
    end
  end
end
