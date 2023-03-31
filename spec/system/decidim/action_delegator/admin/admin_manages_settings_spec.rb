# frozen_string_literal: true

require "spec_helper"

describe "Admin manages settings", type: :system do
  include Decidim::TranslationsHelper

  let(:i18n_scope) { "decidim.action_delegator.admin" }
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let(:available_authorizations) { ["delegations_verifier"] }
  let!(:consultation) { create(:consultation, organization: organization) }
  let!(:authorization) { create(:authorization, user: another_user, name: "delegations_verifier", granted_at: Time.current) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization, email: "bar@example.org") }
  let!(:another_user) { create(:user, :confirmed, organization: organization) }

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
    let(:participants) { [] }
    let(:authorization_method) { :both }
    let!(:setting) { create(:setting, consultation: consultation, participants: participants, authorization_method: authorization_method) }

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

    it "shows a callout with information" do
      expect(page).to have_content("All questions are restricted by the Delegations Verifier")
      expect(page).to have_content("There is no census! Please, add participants or nobody will be able to vote if Delegations Verifier is active")
    end

    context "when there are participants" do
      let(:email) { "foo@example.org" }
      let(:phone) { "123456789" }
      let(:participants) { [build(:participant, email: email, phone: phone)] }
      let(:seed) { "something" }
      let(:uniq_id) { Digest::MD5.hexdigest("#{seed}-#{organization.id}-#{Digest::MD5.hexdigest(Rails.application.secret_key_base)}") }

      it "complains about registration" do
        expect(page).to have_content("All questions are restricted by the Delegations Verifier")
        expect(page).to have_content("There are 1 participants that are not registered into the platform")
        expect(page).to have_content("There are 1 participants that are not verified by the Delegations Verifier")
        expect(page).to have_css(".callout.warning")
      end

      context "when participants are registered" do
        let(:email) { user.email }

        it "complains about verification" do
          expect(page).to have_content("All questions are restricted by the Delegations Verifier")
          expect(page).to have_content("All participants are registered into the platform")
          expect(page).to have_content("There are 1 participants that are not verified by the Delegations Verifier")
          expect(page).to have_css(".callout.warning")
        end

        context "when participants are verified" do
          let!(:authorization) { create(:authorization, user: user, name: "delegations_verifier", unique_id: uniq_id, granted_at: Time.current) }

          it "is happy" do
            expect(page).to have_content("All questions are restricted by the Delegations Verifier")
            expect(page).to have_content("All participants are registered into the platform")
            expect(page).to have_content("All participants are verified by the Delegations Verifier")
            expect(page).to have_css(".callout.success")
          end

          context "and unque_id is by email" do
            let(:seed) { phone }
            let(:email) { "another@email" }

            it "is happy" do
              expect(page).to have_content("All participants are verified by the Delegations Verifier")
            end
          end
        end
      end
    end

    context "when verifier is not installed" do
      let(:available_authorizations) { [] }

      it "alerts with a message" do
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
