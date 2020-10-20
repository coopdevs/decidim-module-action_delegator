# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe SmsGateway do
    let(:subject) { described_class.new(mobile_phone_number, code) }
    let(:mobile_phone_number) { "+12 345 678 901" }
    let(:code) { "1a4s9b" }
    let(:response_body) { { send_sms_response: { result: result } } }

    describe "#deliver_code" do
      it "enqueues a SendSmsJob" do
        expect { subject.deliver_code }.to have_enqueued_job(SendSmsJob)
      end
    end
  end
end
