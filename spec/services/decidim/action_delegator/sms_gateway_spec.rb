# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe SmsGateway do
    let(:subject) { described_class.new(mobile_phone_number, code) }
    let(:mobile_phone_number) { "+12 345 678 901" }
    let(:code) { "1a4s9b" }
    let(:client) { double("client") }
    let(:response) { double("response") }
    let(:response_body) { { send_sms_response: { result: result } } }

    describe "#deliver_code" do
      before do
        allow(Savon).to receive(:client).and_return(client)
        allow(client).to receive(:call).and_return(response)
        allow(response).to receive(:body).and_return(response_body)
      end

      context "when code's result is 200" do
        let(:result) { "<xml><codigo>200</codigo><description>Went well</description></xml>" }

        it "returns true" do
          expect(subject.deliver_code).to eq(true)
        end
      end

      context "when code's result isn't 200" do
        let(:result) { "<xml><codigo>115</codigo><description>Woopsie</description></xml>" }

        it "returns false" do
          expect(subject.deliver_code).to eq(false)
        end
      end
    end
  end
end
