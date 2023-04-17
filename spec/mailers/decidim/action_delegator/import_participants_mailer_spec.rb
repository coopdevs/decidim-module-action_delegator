# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe ImportParticipantsMailer, type: :mailer do
      let(:organization) { create :organization }
      let(:current_user) { create :user, organization: organization }
      let(:valid_csv_file) { File.open("spec/fixtures/valid_participants.csv") }
      let(:invalid_csv_file) { File.open("spec/fixtures/invalid_participants.csv") }
      let(:current_setting) { create(:setting, consultation: consultation) }
      let(:consultation) { create(:consultation) }

      describe "#import" do
        context "when the CSV has valid rows" do
          let(:mail) { described_class.import(current_user, import_summary, valid_csv_file.path) }
          let(:importer) { Decidim::ActionDelegator::ParticipantsCsvImporter.new(valid_csv_file, current_user, current_setting) }
          let(:import_summary) { importer.import! }

          it "renders the headers" do
            expect(mail.subject).to eq("Participants imported")
            expect(mail.to).to eq([current_user.email])
          end

          it "renders the body" do
            expect(mail.body).to include("4 rows of 4")
            expect(mail.body).not_to include("errors")
          end

          it "does not attach CSV file if file has valid rows" do
            expect(mail.attachments).to be_empty
          end
        end

        context "when the CSV has invalid rows" do
          let(:mail) { described_class.import(current_user, import_summary, invalid_csv_file.path) }
          let(:importer) { Decidim::ActionDelegator::ParticipantsCsvImporter.new(invalid_csv_file, current_user, current_setting) }
          let(:import_summary) { importer.import! }

          it "renders the headers" do
            expect(mail.subject).to eq("Participants imported")
            expect(mail.to).to eq([current_user.email])
          end

          it "renders the body" do
            expect(mail.body.parts[0].body.raw_source).to include("2 rows of 5")
            expect(mail.body.parts[0].body.raw_source).to include("2 errors")
          end

          it "attaches CSV file if file has invalid rows" do
            expect(mail.attachments["details.csv"]).not_to be_nil
          end
        end
      end
    end
  end
end
