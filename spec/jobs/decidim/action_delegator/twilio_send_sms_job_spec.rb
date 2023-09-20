# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe TwilioSendSmsJob do
    subject { described_class }

    let(:sender) { "Sender" }
    let(:mobile_phone_number) { "+12 345 6789" }
    let(:message) { "A very important message" }

    let(:client) { double("client") }
    let(:messages) { double(:messages) }

    describe "queue" do
      it "is queued to default" do
        expect(subject.queue_name).to eq "default"
      end
    end

    describe "#perform" do
      before do
        allow(::Twilio::REST::Client).to receive(:new).and_return(client)
        allow(client).to receive(:messages).and_return(messages)
        allow(messages).to receive(:create).and_return(true)
      end

      it "creates a message through Twilio's client" do
        expect(subject.perform_now(sender, mobile_phone_number, message)).to be true
      end
    end
  end
end
