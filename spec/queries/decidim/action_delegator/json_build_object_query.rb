# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe JsonBuildObjectQuery do
      subject(:json_query) { described_class.new({ 1 => 0, 2 => 0 }, Arel.sql("foo"), "alias") }

      describe "#to_sql" do
        it "returns JSON query of the specified array and field" do
          expect(json_query.to_sql).to eq("JSON_BUILD_OBJECT(1, 0, 2, 0) ->> CAST((foo) AS TEXT) AS alias")
        end
      end
    end
  end
end
