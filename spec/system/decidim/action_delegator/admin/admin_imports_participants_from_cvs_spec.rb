# frozen_string_literal: true

require "spec_helper"

describe "Admin imports participants from cvs", type: :system do
  include Decidim::TranslationsHelper

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:consultation) { create(:consultation, organization: organization) }
  let(:delegate) { create(:user, :confirmed, organization: organization) }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:valid_csv_file) { File.open("spec/fixtures/valid_participants.csv") }
  let(:invalid_csv_file) { File.open("spec/fixtures/invalid_participants.csv") }
  let(:repeated_data_csv_file) { File.open("spec/fixtures/repeated_data_participants.csv") }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.users_path
    click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    click_link I18n.t("decidim.action_delegator.admin.settings.index.actions.new_setting")

    within ".new_setting" do
      fill_in :setting_max_grants, with: 5
      select translated_attribute(consultation.title), from: :setting_decidim_consultation_id

      find("*[type=submit]").click
    end

    click_link I18n.t("decidim.action_delegator.admin.settings.index.actions.census")
    click_link I18n.t("decidim.action_delegator.admin.participants.index.actions.csv_import")
  end

  def import_csv(file)
    attach_file "csv_file", file.path
    click_button "Import"
    perform_enqueued_jobs
    visit current_url
  end

  context "when CSV file was imported" do
    it "shows the flash" do
      attach_file "csv_file", valid_csv_file.path
      click_button "Import"

      expect(page).to have_content("The import process has started")
    end
  end

  context "when the CSV has valid rows" do
    it "imports the participants" do
      import_csv(valid_csv_file)

      expect(page).to have_selector("tr[data-participant-id]", count: 4)
    end
  end

  context "when the CSV has invalid rows" do
    it "does not import the participants" do
      import_csv(invalid_csv_file)

      expect(page).to have_selector("tr[data-participant-id]", count: 2)
    end
  end

  context "when participant with this email already exists" do
    let(:participant) { create(:participant, email: "foo@example.org") }

    it "does not import the participants" do
      import_csv(valid_csv_file)

      expect(page).to have_selector("tr[data-participant-id]", count: 4)
      expect(page).to have_content("foo@example.org", count: 1)
    end
  end

  context "when users already exists" do
    emails = %w(foo@example.org bar@example.org baz@example.org)
    users = []

    before do
      users = emails.map do |email|
        create(:user, :admin, :confirmed, organization: organization, email: email)
      end
    end

    it "shows user names" do
      import_csv(valid_csv_file)

      expect(page).to have_selector("tr[data-participant-id]", count: 4)
      expect(page).to have_content(users[0].name, count: 1)
      expect(page).to have_content(users[1].name, count: 1)
      expect(page).to have_content(users[2].name, count: 1)
    end
  end

  context "when repeated data" do
    it "does not import the repeated participants" do
      import_csv(repeated_data_csv_file)

      expect(page).to have_selector("tr[data-participant-id]", count: 4)
    end
  end

  context "when imported existing participants" do
    it "does not update tha data of existing users in the table" do
      import_csv(valid_csv_file)
      click_link I18n.t("decidim.action_delegator.admin.participants.index.actions.csv_import")
      import_csv(repeated_data_csv_file)

      expect(page).to have_selector("tr[data-participant-id]", count: 4)
      expect(page).to have_content("9660000", count: 0)
    end
  end
end
