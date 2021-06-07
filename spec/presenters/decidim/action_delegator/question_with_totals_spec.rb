# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe QuestionWithTotals do
      subject { described_class.new(question, questions_by_id) }

      let(:question) { create(:question) }
      let(:questions_by_id) { { question.id => 2 } }

      describe "#total_delegates" do
        it "returns the count of its delegated votes" do
          expect(subject.total_delegates).to eq(2)
        end
      end
    end
  end
end
