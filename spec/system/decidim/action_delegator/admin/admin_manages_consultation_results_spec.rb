# frozen_string_literal: true

require "spec_helper"

describe "Admin manages consultation results", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:total_votes) { I18n.t("decidim.admin.consultations.results.total_votes", count: votes) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.results_consultation_path(consultation)
  end

  context "when viewing a finished consultation with votes" do
    let!(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
    let!(:question) { create(:question, consultation: consultation) }
    let!(:response) { create(:response, question: question) }

    let!(:vote) { question.votes.create(author: user, response: response) }

    let!(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:other_vote) { question.votes.create(author: other_user, response: response) }

    let!(:authorization) do
      create(:authorization, user: user, metadata: { membership_type: "producer", membership_weight: 2 })
    end
    let!(:other_authorization) do
      create(:authorization, user: other_user, metadata: { membership_type: "consumer", membership_weight: 3 })
    end

    let(:votes) { consultation.questions.first.total_votes }

    it "shows votes total" do
      visit decidim_admin_consultations.results_consultation_path(consultation)
      expect(page).to have_content(/#{total_votes}/i)
      expect(page).to have_content(/#{translated(consultation.questions.first.responses.first.title)}/i)
    end

    it "shows votes by membership and weight type" do
      visit decidim_admin_consultations.results_consultation_path(consultation)

      expect(page).to have_content(I18n.t("decidim.admin.consultations.results.membership_type").upcase)
      expect(page).to have_content(I18n.t("decidim.admin.consultations.results.membership_weight").upcase)

      first_row = find(:xpath, ".//table/tbody/tr[1]")
      expect(first_row.find(".membership-type")).to have_content("consumer")
      expect(first_row.find(".membership-weight")).to have_content(3)
      expect(first_row.find(".votes-count")).to have_content(1)

      second_row = find(:xpath, ".//table/tbody/tr[2]")
      expect(second_row.find(".membership-type")).to have_content("producer")
      expect(second_row.find(".membership-weight")).to have_content(2)
      expect(second_row.find(".votes-count")).to have_content(1)
    end
  end
end
