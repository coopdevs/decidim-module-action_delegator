# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe SumOfWeightsSerializer do
    subject { described_class.new(result) }

    let(:result) do
      double(
        :result,
        question_title: "question title",
        title: { "ca" => "A" },
        votes_count: 2
      )
    end

    describe "#serialize" do
      it "includes all attributes" do
        expect(subject.serialize).to eq(
          question: "question title",
          response: "A",
          votes_count: 2
        )
      end
    end
  end
end
