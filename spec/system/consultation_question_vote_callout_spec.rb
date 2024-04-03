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
      expect(page).to have_content("Review the summary of your vote here")
      expect(page).to have_content(I18n.t("decidim.questions.vote_button.vote").upcase)
      expect(page).to have_content("You have answered 0 from a total of 1 questions")
    end

    it "renders callout" do
      click_link("Review the summary of your vote here")
      within "#consultations-questions-modal" do
        expect(page).to have_content("Did you answer?")
        expect(page).to have_content("Your votes in \"#{question.title["en"]}\"")
        expect(page).to have_content(I18n.t("decidim.action_delegator.questions.modal.modal_votes_title"))
        expect(page).to have_link("No, take me there", href: decidim_consultations.question_path(question))
      end
    end
  end
end
