# frozen_string_literal: true

require "spec_helper"

describe "Visit a consultation", type: :system do
  let(:organization) { create :organization, available_locales: [:en] }
  let!(:consultation) { create :consultation, :published, organization: organization }
  let!(:question) { create :question, consultation: consultation }
  let!(:hihglighted_question) { create :question, consultation: consultation, decidim_scope_id: consultation.decidim_highlighted_scope_id }
  let(:user) { create :user, :confirmed, :admin, organization: organization }

  before do
    switch_to_host(organization.host)
  end

  context "when public view" do
    shared_examples "renders questions" do
      it "renders the questions once only" do
        expect(page).to have_content(translated(question.title), count: 1)
        expect(page).to have_content(translated(hihglighted_question.title), count: 1)
      end
    end

    before do
      visit decidim_consultations.consultation_path(consultation)
    end

    it_behaves_like "renders questions"

    context "when question has no scopes" do
      let(:question) { create :question, consultation: consultation, decidim_scope_id: nil }

      it_behaves_like "renders questions"
    end
  end

  context "when admin" do
    before do
      login_as user, scope: :user
      visit decidim_admin_consultations.consultations_path
    end

    it "does not show the deprecation warning" do
      expect(page).not_to have_content("Consultations module will be deprecated in the near future.")
    end
  end
end
