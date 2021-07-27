# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe VotesCountAggregation do
      subject(:aggregation) { described_class.new(Arel.sql("foo"), "alias") }

      describe "#to_sql" do
        it "returns the SUM of the specified field" do
          expect(aggregation.to_sql).to eq("SUM(COALESCE(CAST((foo) AS INTEGER), 1)) AS alias")
        end
      end
    end
  end
end
