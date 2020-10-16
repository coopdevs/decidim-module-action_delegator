# frozen_string_literal: true

require "savon"

module Decidim
  module ActionDelegator
    class SendSmsJob < ApplicationJob
      queue_as :default

      def perform(mobile_phone_number)
        client = ::Savon.client(wsdl: "https://websms.masmovil.com/api_php/smsvirtual.wsdl")

        response = client.call(:send_sms,
                               message: {
                                 user: ENV["SMS_USER"],
                                 pass: ENV["SMS_PASS"],
                                 src: "Coopcat",
                                 dst: mobile_phone_number,
                                 msg: "Test"
                               })

        Rails.logger.debug response
      end
    end
  end
end
