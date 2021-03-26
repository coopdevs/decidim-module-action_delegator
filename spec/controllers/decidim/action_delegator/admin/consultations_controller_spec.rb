# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Admin::ConsultationsController, type: :controller do
      routes { Decidim::ActionDelegator::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, organization: organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user
      end

      describe "#results" do
        let(:question) { create(:question, consultation: consultation) }
        let(:question_response) { create(:response, question: question, title: { "ca" => "A" }) }

        before do
          question.votes.create(author: user, response: question_response)
        end

        it "renders decidim/admin/consultation layout" do
          get :results, params: { slug: consultation.slug }
          expect(response).to render_template("layouts/decidim/admin/consultation")
        end

        context "when the consultation is not finished" do
          let(:consultation) { create(:consultation, :unpublished, organization: organization) }

          it "does not load any response" do
            get :results, params: { slug: consultation.slug }
            expect(assigns(:responses)).to be_empty
          end
        end

        context "when the consultation is finished" do
          let(:consultation) { create(:consultation, :finished, organization: organization) }

          it "loads the question's total participants without an N+1" do
            get :results, params: { slug: consultation.slug }
            questions = assigns(:questions)
            expect(questions.first.num_participants).to eq(1)
          end

          it "loads the responses" do
            get :results, params: { slug: consultation.slug }
            expect(assigns(:responses)).not_to be_empty
          end
        end
      end
    end
  end
end
