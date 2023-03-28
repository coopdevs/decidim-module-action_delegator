# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Settings, type: :model do
      subject { build(:setting, consultation: consultation, verify_with_sms: verify_with_sms, phone_freezed: phone_freezed) }

      let(:verify_with_sms) { false }
      let(:phone_freezed) { false }
      let(:consultation) { create(:consultation, start_voting_date: start_voting_date, end_voting_date: end_voting_date) }
      let(:start_voting_date) { 1.day.ago }
      let(:end_voting_date) { 1.day.from_now }

      it { is_expected.to belong_to(:consultation) }
      it { is_expected.to have_many(:delegations).dependent(:destroy) }

      it { is_expected.to validate_presence_of(:max_grants) }
      it { is_expected.to validate_numericality_of(:max_grants).is_greater_than(0) }

      it "returns the consultation title" do
        expect(subject.title).to eq(consultation.title)
      end

      it "returns the state" do
        expect(subject.state).to eq(:ongoing)
        expect(subject).to be_ongoing
        expect(subject).to be_editable
      end

      it "returns the phone config" do
        expect(subject.phone_config).to eq(:none)
      end

      context "when the consultation is finished" do
        let(:end_voting_date) { 1.day.ago }

        it "returns the state" do
          expect(subject.state).to eq(:closed)
          expect(subject).not_to be_ongoing
          expect(subject).not_to be_editable
        end
      end

      context "when the consultation is not yet started" do
        let(:start_voting_date) { 1.day.from_now }

        it "returns the state" do
          expect(subject.state).to eq(:pending)
          expect(subject).to be_editable
          expect(subject).not_to be_ongoing
        end
      end

      context "when the consultation is configured to verify with sms" do
        let(:verify_with_sms) { true }

        it "returns the phone config" do
          expect(subject.phone_config).to eq(:open)
        end

        context "when the phone is freezed" do
          let(:phone_freezed) { true }

          it "returns the phone config" do
            expect(subject.phone_config).to eq(:freezed)
          end
        end
      end
    end
  end
end
