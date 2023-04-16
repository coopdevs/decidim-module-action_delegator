# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ActionDelegator::Admin::ImportParticipantsCsvJob, type: :job do
  let(:current_user) { create(:user) }
  let(:valid_csv_file) { File.open("spec/fixtures/valid_participants.csv") }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:consultation) { create(:consultation) }
  let(:importer) { Decidim::ActionDelegator::ParticipantsCsvImporter.new(valid_csv_file, current_user, current_setting) }
  let(:import_summary) { importer.import! }

  before do
    allow(Decidim::ActionDelegator::ParticipantsCsvImporter).to receive(:new).with(valid_csv_file, current_user, current_setting).and_return(importer)
    allow(importer).to receive(:import!).and_return(import_summary)
    allow(Decidim::ActionDelegator::ImportParticipantsMailer)
      .to receive(:import)
      .with(current_user, import_summary, "spec/fixtures/details.csv")
      .and_return(double("mailer", deliver_now: true))

  end

  it "imports participants CSV file and sends email notification" do
    expect { described_class.perform_now(current_user, valid_csv_file, current_setting) }.not_to raise_error
    expect(importer).to have_received(:import!).once
    expect(Decidim::ActionDelegator::ImportParticipantsMailer)
      .to have_received(:import)
      .once
      .with(current_user, import_summary, "spec/fixtures/details.csv")
  end

  it "handles errors during import" do
    allow(importer).to receive(:import!).and_raise(StandardError.new("Import error"))
    expect { described_class.perform_now(current_user, valid_csv_file, current_setting) }.to raise_error(StandardError, "Import error")
  end
end
