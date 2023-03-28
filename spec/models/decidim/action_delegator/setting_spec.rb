# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Setting, type: :model do
      subject { build(:setting, consultation: consultation, authorization_method: authorization_method) }

      let(:authorization_method) { :email }
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
    end
  end
end
