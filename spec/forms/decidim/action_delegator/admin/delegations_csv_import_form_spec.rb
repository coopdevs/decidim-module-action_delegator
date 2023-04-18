# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::DelegationsCsvImportForm do
  subject { described_class.from_params(attributes) }

  let(:file) { file_fixture("import_delegations.csv") }
  let(:attributes) do
    {
      "file" => file
    }
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when file is missing" do
    let(:file) { nil }

    it { is_expected.to be_invalid }
  end
end
