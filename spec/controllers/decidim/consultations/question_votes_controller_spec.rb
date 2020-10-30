# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe QuestionVotesController, type: :controller do
      routes { Decidim::Consultations::Engine.routes }

      let(:organization) { create :organization }
      let(:user) { create(:user, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "#destroy" do
        let(:consultation) { create(:consultation, organization: organization) }
        let(:question) { create(:question, consultation: consultation) }
        let(:setting) { create(:setting, consultation: consultation) }

        context "when a delegation is specified" do
          let(:delegation) { create(:delegation, setting: setting, grantee: user) }

          before { create(:vote, author: delegation.granter, question: question) }

          it "destroys the vote" do
            delete :destroy, params: { question_slug: question.slug, decidim_consultations_delegation_id: delegation.id }, format: :js
            expect(response).to render_template(:update_vote_button)
          end
        end

        context "when no delegation is specified" do
          before { create(:vote, author: user, question: question) }

          it "destroys the vote" do
            delete :destroy, params: { question_slug: question.slug }, format: :js
            expect(response).to render_template(:update_vote_button)
          end
        end
      end
    end
  end
end

