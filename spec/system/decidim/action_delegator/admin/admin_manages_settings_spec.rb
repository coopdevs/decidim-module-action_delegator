# frozen_string_literal: true

require "spec_helper"

describe "Admin manages settings", type: :system do
  include Decidim::TranslationsHelper

  let(:i18n_scope) { "decidim.action_delegator.admin" }
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let(:available_authorizations) { ["delegations_verifier"] }
  let!(:consultation) { create(:consultation, organization: organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  context "when creating settings" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")

      click_link I18n.t("decidim.action_delegator.admin.settings.index.actions.new_setting")
    end

    it "creates a new setting" do
      within ".new_setting" do
        fill_in :setting_max_grants, with: 5
        select translated_attribute(consultation.title), from: :setting_decidim_consultation_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content(translated_attribute(consultation.title))
      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)
    end
  end

  context "when listing settings" do
    let!(:setting) { create(:setting, consultation: consultation) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    end

    it "renders the list of settings in a table" do
      expect(page).to have_no_content('"Delegation Verifier" authorization method is not installed')
      expect(page).to have_content(I18n.t("decidim.action_delegator.admin.settings.index.title"))

      expect(page).to have_content(I18n.t("settings.index.consultation", scope: i18n_scope))
      expect(page).to have_content(I18n.t("settings.index.created_at", scope: i18n_scope))

      expect(page).to have_content(translated_attribute(consultation.title))
      expect(page).to have_content(I18n.l(setting.created_at, format: :short))
    end

    it "links to the consultation" do
      expect(page).to have_selector(
        :xpath,
        "//a[@href='#{decidim_consultations.consultation_path(consultation)}'][@target='blank']"
      )
    end

    it "links to edit the setting" do
      click_link "Edit"
      expect(page).to have_current_path(decidim_admin_action_delegator.edit_setting_path(setting))
    end

    it "links to the setting's delegations" do
      click_link "Edit the delegations"
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_delegations_path(setting))
    end

    it "links to the setting's participants" do
      click_link "Edit the census"
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_participants_path(setting))
    end

    it "links to the setting's ponderations" do
      click_link "Set weights for vote ponderation"
      expect(page).to have_current_path(decidim_admin_action_delegator.setting_ponderations_path(setting))
    end

    context "when verifier is installed" do
      let(:available_authorizations) { [] }

      it "does not show the verifier link" do
        expect(page).to have_content('"Delegation Verifier" authorization method is not installed')
      end
    end
  end

  context "when removing settings" do
    let!(:setting) { create(:setting, consultation: consultation) }
    let!(:delegation) { create(:delegation, setting: setting) }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.users_path
      click_link I18n.t("decidim.action_delegator.admin.menu.delegations")
    end

    it "removes the setting" do
      within "tr[data-setting-id=\"#{setting.id}\"]" do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_current_path(decidim_admin_action_delegator.settings_path)
      expect(page).to have_no_content(translated_attribute(consultation.title))
    end
  end
end
