# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ActionDelegator::Admin::ImportCsvJob, type: :job do
  let(:current_user) { create(:user) }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:consultation) { create(:consultation) }

  describe "import delegations" do
    let(:valid_csv_file) { File.open("spec/fixtures/valid_delegations.csv") }
    let(:importer) { Decidim::ActionDelegator::DelegationsCsvImporter.new(valid_csv_file, current_user, current_setting) }
    let(:import_summary) { importer.import! }

    let!(:granter_email) { "granter@example.org" }
    let!(:grantee_email) { "grantee@example.org" }
    let!(:granter) { create(:user, email: granter_email) }
    let!(:grantee) { create(:user, email: grantee_email) }

    before do
      allow(Decidim::ActionDelegator::DelegationsCsvImporter).to receive(:new).with(valid_csv_file, current_user, current_setting).and_return(importer)
      allow(importer).to receive(:import!).and_return(import_summary)
      allow(Decidim::ActionDelegator::ImportMailer)
        .to receive(:import)
        .with(current_user, import_summary, "spec/fixtures/details.csv")
        .and_return(double("mailer", deliver_later: true))
    end

    it "imports delegations CSV file and sends email notification" do
      expect { described_class.perform_now(importer, current_user) }.not_to raise_error
      expect(importer).to have_received(:import!).once
      expect(Decidim::ActionDelegator::ImportMailer)
        .to have_received(:import)
        .once
        .with(current_user, import_summary, "spec/fixtures/details.csv")
    end

    it "handles errors during import" do
      allow(importer).to receive(:import!).and_raise(StandardError.new("Import error"))
      expect { described_class.perform_now(importer, current_user) }.to raise_error(StandardError, "Import error")
    end
  end

  describe "import participants" do
    let(:valid_csv_file) { File.open("spec/fixtures/valid_participants.csv") }
    let(:importer) { Decidim::ActionDelegator::ParticipantsCsvImporter.new(valid_csv_file, current_user, current_setting) }
    let(:import_summary) { importer.import! }

    before do
      allow(Decidim::ActionDelegator::ParticipantsCsvImporter).to receive(:new).with(valid_csv_file, current_user, current_setting).and_return(importer)
      allow(importer).to receive(:import!).and_return(import_summary)
      allow(Decidim::ActionDelegator::ImportMailer)
        .to receive(:import)
        .with(current_user, import_summary, "spec/fixtures/details.csv")
        .and_return(double("mailer", deliver_later: true))
    end

    it "imports participants CSV file and sends email notification" do
      expect { described_class.perform_now(importer, current_user) }.not_to raise_error
      expect(importer).to have_received(:import!).once
      expect(Decidim::ActionDelegator::ImportMailer)
        .to have_received(:import)
        .once
        .with(current_user, import_summary, "spec/fixtures/details.csv")
    end

    it "handles errors during import" do
      allow(importer).to receive(:import!).and_raise(StandardError.new("Import error"))
      expect { described_class.perform_now(importer, current_user) }.to raise_error(StandardError, "Import error")
    end
  end
end
