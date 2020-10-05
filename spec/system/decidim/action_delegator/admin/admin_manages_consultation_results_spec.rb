# frozen_string_literal: true

require "spec_helper"

describe "Admin manages consultation results", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:total_votes) { I18n.t("decidim.admin.consultations.results.total_votes", count: votes) }

  let!(:question) { create(:question, consultation: consultation) }
  let!(:response) do
    create(
      :response,
      question: question,
      title: { "en" => "A", "ca" => "A", "es" => "A" }
    )
  end
  let!(:other_response) do
    create(
      :response,
      question: question,
      title: { "en" => "B", "ca" => "B", "es" => "B" }
    )
  end

  let!(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:another_user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:yet_another_user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:votes) { consultation.questions.first.total_votes }

  before do
    question.votes.create(author: user, response: response)
    question.votes.create(author: other_user, response: response)
    question.votes.create(author: another_user, response: response)
    question.votes.create(author: yet_another_user, response: other_response)

    create(:authorization, user: user, metadata: { membership_type: "producer", membership_weight: 2 })
    create(:authorization, user: other_user, metadata: { membership_type: "consumer", membership_weight: 3 })
    create(:authorization, user: another_user, metadata: { membership_type: "consumer", membership_weight: 1 })

    create(:authorization, user: yet_another_user, metadata: { membership_type: "consumer", membership_weight: 1 })

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.results_consultation_path(consultation)
  end

  context "when viewing a finished consultation with votes" do
    let!(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }

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

    it "enables exporting to CSV" do
      visit decidim_admin_consultations.results_consultation_path(consultation)

      perform_enqueued_jobs { click_link(I18n.t("decidim.admin.consultations.results.export")) }

      expect(page).to have_content(I18n.t("decidim.admin.exports.notice"))

      expect(last_email.subject).to include("results", "csv")
      expect(last_email.attachments.first.filename).to match(/^consultation_results.*\.zip$/)
    end
  end

  context "when viewing an unfinished consultation" do
    let!(:consultation) { create(:consultation, :active, :unpublished_results, organization: organization) }

    it "disables the export button" do
      visit decidim_admin_consultations.results_consultation_path(consultation)

      within "#export-consultation-results" do
        expect(page).to have_css(".disabled")
        expect(page).not_to have_link(I18n.t("decidim.admin.consultations.results.export"))
      end
    end
  end

  def nth_row(number)
    find(:xpath, ".//table/tbody/tr[#{number}]")
  end
end
