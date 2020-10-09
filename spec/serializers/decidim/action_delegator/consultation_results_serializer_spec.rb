# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe ConsultationResultsSerializer do
    let(:subject) { described_class.new(result) }
    let(:result) do
      double(
        :result,
        title: { "en" => "A", "ca" => "A", "es" => "A" },
        membership_type: "consumer",
        membership_weight: 2,
        votes_count: 2
      )
    end

    describe "#serialize" do
      it "includes all attributes" do
        expect(subject.serialize).to eq(
          title: translated(result.title),
          membership_type: "consumer",
          votes_count: 2,
          membership_weight: 2
        )
      end
    end
  end
end
