# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::ParticipantsCsvImporter do
  let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:valid_csv_file) { File.open("spec/fixtures/valid_participants.csv") }
  let(:invalid_csv_file) { File.open("spec/fixtures/invalid_participants.csv") }

  describe "#import!" do
    context "when the rows in the csv file are valid" do
      subject { described_class.new(valid_csv_file, current_user, current_setting) }

      it "Import all rows from csv file" do
        expect do
          subject.import!
        end.to change(Decidim::ActionDelegator::Participant, :count).by(4)
      end

      it "returns a summary of the import" do
        import_summary = subject.import!

        expect(import_summary[:error_rows]).to eq []
        expect(import_summary[:imported_rows]).to eq 4
        expect(import_summary[:total_rows]).to eq 4
      end
    end

    context "when the rows in the csv file are not valid" do
      subject { described_class.new(invalid_csv_file, current_user, current_setting) }

      it "creates participants from valid rows" do
        expect do
          subject.import!
        end.to change(Decidim::ActionDelegator::Participant, :count).by(2)
      end

      it "returns a summary of the import" do
        import_summary = subject.import!

        expect(import_summary[:error_rows].pluck(:row_number)).to eq [1, 4]
        expect(import_summary[:imported_rows]).to eq 2
        expect(import_summary[:total_rows]).to eq 4
      end
    end

    context "when participant with this email already exists" do
      subject { described_class.new(valid_csv_file, current_user, current_setting) }

      let!(:participant) { create(:participant, email: "baz@example.org", setting: current_setting) }

      it "does not create a new participant" do
        expect do
          subject.import!
        end.to change(Decidim::ActionDelegator::Participant, :count).by(3)
      end
    end
  end
end
