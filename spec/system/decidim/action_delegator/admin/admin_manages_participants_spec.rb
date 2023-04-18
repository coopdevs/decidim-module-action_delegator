# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participants", type: :system do
  let(:i18n_scope) { "decidim.action_delegator.admin" }
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when listing participants" do
    let(:consultation) { create(:consultation, organization: organization) }
    let(:setting) { create(:setting, consultation: consultation) }
    let!(:participant) { create(:participant, setting: setting) }

    let!(:collection) { create_list :participant, collection_size, setting: setting }
    let!(:resource_selector) { "[data-participant-id]" }
    let(:collection_size) { 30 }

    before do
      visit decidim_admin_action_delegator.setting_participants_path(setting)
    end

    it "lists 20 resources per page by default" do
      expect(page).to have_css(resource_selector, count: 20)
      expect(page).to have_css(".pagination .page", count: 2)
      # none has voted
      expect(page).to have_content("No", count: 20)
    end
  end

  context "when creating a participant" do
    let!(:consultation) { create(:consultation, organization: organization) }
    let!(:setting) { create(:setting, consultation: consultation) }

    before do
      visit decidim_admin_action_delegator.setting_participants_path(setting)
    end

    it "creates a new participant" do
      click_link I18n.t("participants.index.actions.new_participant", scope: i18n_scope)

      within ".new_participant" do
        fill_in :participant_email, with: "foo@example.org"
        fill_in :participant_phone, with: "12345"

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("foo@example.org")
      expect(page).to have_content("12345")
      expect(page).to have_i18n_content(consultation.title)
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_participants_path(setting.id))
    end
  end

  context "when destroying a participant" do
    let(:consultation) { create(:consultation, organization: organization) }
    let(:question) { create(:question, consultation: consultation) }
    let(:response) { create(:response, question: question) }
    let!(:vote) { create(:vote, question: question, response: response) }
    let(:setting) { create(:setting, consultation: consultation) }
    let!(:participant) { create(:participant, setting: setting, decidim_user: user) }

    before do
      visit decidim_admin_action_delegator.setting_participants_path(setting)
    end

    it "destroys the participant" do
      expect(page).to have_content(participant.email)
      expect(page).to have_content(participant.phone)
      # has not voted
      expect(page).to have_content("No")
      within "tr[data-participant-id=\"#{participant.id}\"]" do
        accept_confirm { click_link "Delete" }
      end

      expect(page).not_to have_content(participant.email)
      expect(page).not_to have_content(participant.phone)
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_participants_path(setting.id))
      expect(page).to have_admin_callout("successfully")
    end

    context "when participant has voted" do
      let!(:vote) { create(:vote, question: question, response: response, author: user) }

      it "does not destroy the participant" do
        expect(page).to have_content(participant.email)
        expect(page).to have_content(participant.phone)
        # has voted
        expect(page).to have_content("Yes")
        within "tr[data-participant-id=\"#{participant.id}\"]" do
          expect(page).not_to have_link("Delete")
        end
      end
    end
  end

  context "when removing census" do
    let(:consultation) { create(:consultation, organization: organization) }
    let(:setting) { create(:setting, consultation: consultation) }
    let!(:participants) { create_list(:participant, 3, setting: setting) }

    before do
      visit decidim_admin_action_delegator.setting_participants_path(setting)
    end

    it "removes the census" do
      participants.each do |participant|
        expect(page).to have_content(participant.email)
      end

      accept_confirm { click_link "Remove census" }

      expect(page).to have_content("successfully")

      participants.each do |participant|
        expect(page).not_to have_content(participant.email)
      end
    end
  end
end
