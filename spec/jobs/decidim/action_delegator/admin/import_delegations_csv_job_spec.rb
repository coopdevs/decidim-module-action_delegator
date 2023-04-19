# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ActionDelegator::Admin::ImportDelegationsCsvJob, type: :job do
  let(:current_user) { create(:user) }
  let(:valid_csv_file) { File.open("spec/fixtures/valid_delegations.csv") }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:consultation) { create(:consultation) }
  let(:importer) { Decidim::ActionDelegator::DelegationsCsvImporter.new(valid_csv_file, current_user, current_setting) }
  let(:import_summary) { importer.import! }

  let!(:granter_email) { "granter@example.org" }
  let!(:grantee_email) { "grantee@example.org" }
  let!(:granter) { create(:user, email: granter_email) }
  let!(:grantee) { create(:user, email: grantee_email) }

  before do
    allow(Decidim::ActionDelegator::DelegationsCsvImporter).to receive(:new).with(valid_csv_file, current_user, current_setting).and_return(importer)
    allow(importer).to receive(:import!).and_return(import_summary)
    allow(Decidim::ActionDelegator::ImportDelegationsMailer)
      .to receive(:import)
      .with(current_user, import_summary, "spec/fixtures/delegations_details.csv")
      .and_return(double("mailer", deliver_later: true))
  end

  it "imports delegations CSV file and sends email notification" do
    expect { described_class.perform_now(current_user, valid_csv_file, current_setting) }.not_to raise_error
    expect(importer).to have_received(:import!).once
    expect(Decidim::ActionDelegator::ImportDelegationsMailer)
      .to have_received(:import)
      .once
      .with(current_user, import_summary, "spec/fixtures/delegations_details.csv")
  end

  it "handles errors during import" do
    allow(importer).to receive(:import!).and_raise(StandardError.new("Import error"))
    expect { described_class.perform_now(current_user, valid_csv_file, current_setting) }.to raise_error(StandardError, "Import error")
  end
end
