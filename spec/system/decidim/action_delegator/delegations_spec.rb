# frozen_string_literal: true

require "spec_helper"

describe "Delegation vote", type: :system do
  let(:organization) { create(:organization) }
  let(:question) { create :question, :published, consultation: consultation }

  context "when active consultation" do
    let(:consultation) { create(:consultation, :active, organization: organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }

    context "and authenticated user" do
      let!(:response) { create :response, question: question }
      let(:setting) { create(:setting, consultation: consultation) }
      let(:granter) { create(:user, :confirmed, organization: organization) }
      let!(:delegation) { create(:delegation, setting: setting, granter: granter, grantee: user) }

      context "and delegation is not voted" do
        context "and the user didn't vote" do
          before do
            switch_to_host(organization.host)
            login_as user, scope: :user
            visit decidim_consultations.question_path(question)
          end

          it "lets the user vote on behalf of another member" do
            click_link(id: "delegations-button")
            within "#delegations-modal" do
              click_link(I18n.t("decidim.questions.vote_button.vote"))
            end

            expect(page).to have_content(I18n.t("decidim.action_delegator.delegations_modal.callout"))

            click_button translated(response.title)
            click_button I18n.t("decidim.questions.vote_modal_confirm.confirm")

            click_link(I18n.t("decidim.action_delegator.delegations.link"))
            within "#delegations-modal" do
              expect(page).to have_content(t("decidim.questions.vote_button.already_voted").upcase)
            end
          end
        end

        context "and the user already voted" do
          before do
            create(:vote, author: user, question: question)

            switch_to_host(organization.host)
            login_as user, scope: :user
            visit decidim_consultations.question_path(question)
          end

          it "lets the user vote on behalf of another member" do
            click_link(id: "delegations-button")
            within "#delegations-modal" do
              click_link(I18n.t("decidim.questions.vote_button.vote"))
            end

            expect(page).to have_content(I18n.t("decidim.action_delegator.delegations_modal.callout"))

            click_button translated(response.title)
            click_button I18n.t("decidim.questions.vote_modal_confirm.confirm")

            click_link(I18n.t("decidim.action_delegator.delegations.link"))
            within "#delegations-modal" do
              expect(page).to have_content(t("decidim.questions.vote_button.already_voted").upcase)
            end
          end
        end
      end

      context "and delegation is voted" do
        let!(:vote) { create(:vote, author: granter, question: question, response: response) }

        before do
          switch_to_host(organization.host)
          login_as user, scope: :user
          visit decidim_consultations.question_path(question)
        end

        it "lets the user unvote on behalf of another member" do
          click_link(id: "delegations-button")
          within "#delegations-modal" do
            click_button(class: "delegation_unvote_button")
          end

          click_link(I18n.t("decidim.action_delegator.delegations.link"))
          expect(page).to have_link(I18n.t("decidim.questions.vote_button.vote"))
        end
      end
    end
  end
end
