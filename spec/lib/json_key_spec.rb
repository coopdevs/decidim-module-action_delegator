# frozen_string_literal: true

require "spec_helper"
require "json_key"

describe JSONKey do
  let(:node) { described_class.new(json_document, key) }

  describe "#to_sql" do
    let(:json_document) { Arel::Table.new("table")[:document] }
    let(:key) { "key" }

    it "returns PostgreSQL ->> statement to fetch key" do
      expect(node.to_sql).to eq('"table"."document" ->> \'key\'')
    end
  end
end
