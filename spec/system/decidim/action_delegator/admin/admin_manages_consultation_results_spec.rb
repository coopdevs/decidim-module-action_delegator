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
    let!(:response) do
      create(
        :response,
        question: question,
        title: { "en" => "A", "ca" => "A", "es" => "A" }
      )
    end

    let!(:vote) { question.votes.create(author: user, response: response) }

    let!(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:other_vote) { question.votes.create(author: other_user, response: response) }

    let!(:another_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:another_vote) { question.votes.create(author: another_user, response: response) }

    let!(:other_response) do
      create(
        :response,
        question: question,
        title: { "en" => "B", "ca" => "B", "es" => "B" }
      )
    end
    let!(:yet_another_user) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:yet_another_vote) { question.votes.create(author: yet_another_user, response: other_response) }

    before do
      create(:authorization, user: user, metadata: { membership_type: "producer", membership_weight: 2 })
      create(:authorization, user: other_user, metadata: { membership_type: "consumer", membership_weight: 3 })
      create(:authorization, user: another_user, metadata: { membership_type: "consumer", membership_weight: 1 })

      create(:authorization, user: yet_another_user, metadata: { membership_type: "consumer", membership_weight: 1 })
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

      expect(nth_row(1).find(".response-title")).to have_content("A")
      expect(nth_row(1).find(".membership-type")).to have_content("consumer")
      expect(nth_row(1).find(".membership-weight")).to have_content(3)
      expect(nth_row(1).find(".votes-count")).to have_content(1)

      expect(nth_row(2).find(".response-title")).to have_content("A")
      expect(nth_row(2).find(".membership-type")).to have_content("consumer")
      expect(nth_row(2).find(".membership-weight")).to have_content(1)
      expect(nth_row(2).find(".votes-count")).to have_content(1)

      expect(nth_row(3).find(".response-title")).to have_content("A")
      expect(nth_row(3).find(".membership-type")).to have_content("producer")
      expect(nth_row(3).find(".membership-weight")).to have_content(2)
      expect(nth_row(3).find(".votes-count")).to have_content(1)

      expect(nth_row(4).find(".response-title")).to have_content("B")
      expect(nth_row(4).find(".membership-type")).to have_content("consumer")
      expect(nth_row(4).find(".membership-weight")).to have_content(1)
      expect(nth_row(4).find(".votes-count")).to have_content(1)
    end

    def nth_row(number)
      find(:xpath, ".//table/tbody/tr[#{number}]")
    end
  end
end
