# frozen_string_literal: true

require "spec_helper"

describe "Visit a consultation", type: :system do
  let(:organization) { create :organization, available_locales: [:en] }
  let!(:consultation) { create :consultation, :published, organization: organization }
  let!(:question) { create :question, consultation: consultation }
  let!(:hihglighted_question) { create :question, consultation: consultation, decidim_scope_id: consultation.decidim_highlighted_scope_id }
  let(:user) { create :user, :confirmed, :admin, organization: organization }
  let(:enabled) { true }

  before do
    allow(Decidim::ActionDelegator).to receive(:remove_duplicated_highlighted_questions).and_return(enabled)

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_consultations.consultation_path(consultation)
    click_link("Take part", match: :first)
  end

  context "when user logged in" do
    it "can visit the consultation" do
      expect(page).to have_content(I18n.t("decidim.action_delegator.questions.callout_link_text"))
      expect(page).to have_content(I18n.t("decidim.questions.vote_button.vote").upcase)
      expect(page).to have_content(I18n.t("decidim.action_delegator.questions.callout_text"))
    end

    it "renders callout" do
      within ".callout.alert" do
        click_link(I18n.t("decidim.action_delegator.questions.callout_link_text"), wait: 10)
      end
      expect(page).to have_content(I18n.t("decidim.action_delegator.questions.callout_link_toxt"))
    end
  end
end
