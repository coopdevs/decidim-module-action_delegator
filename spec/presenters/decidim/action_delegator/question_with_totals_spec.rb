# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe QuestionWithTotals do
      subject { described_class.new(question, questions_by_id) }

      let(:question) { create(:question) }
      let(:stats) { double(:stats, total_delegates: 2, total_participants: 3) }
      let(:questions_by_id) { { question.id => stats } }

      describe "#total_delegates" do
        it "returns the count of its delegated votes" do
          expect(subject.total_delegates).to eq(2)
        end
      end

      describe "#total_participants" do
        it "returns the count of distinct votes" do
          expect(subject.total_participants).to eq(3)
        end
      end
    end
  end
end
