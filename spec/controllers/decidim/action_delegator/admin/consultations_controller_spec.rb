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

          let(:other_question) { create(:question, consultation: consultation) }
          let(:other_response) { create(:response, question: question) }

          let(:granter) { create(:user, organization: organization) }
          let(:grantee) { create(:user, organization: organization) }
          let(:setting) { create(:setting, consultation: consultation) }

          context "when there are no delegations" do
            before do
              other_question.votes.create(author: user, response: other_response)

              puts "granter_id = #{granter.id}"
              puts "other_question = #{other_question.id}"

              create(:delegation, granter_id: granter.id, grantee_id: grantee.id, setting: setting)
              other_question.votes.create(author: granter, response: other_response)
            end

            it "loads the question's totals without an N+1" do
              get :results, params: { slug: consultation.slug }
              questions = assigns(:questions)

              expect(questions.first.id).to eq(question.id)
              expect(questions.second.id).to eq(other_question.id)

              expect(questions.first.total_delegates).to eq(0)
              expect(questions.second.total_delegates).to eq(1)

              expect(questions.first.total_participants).to eq(1)
              expect(questions.second.total_participants).to eq(2)
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
end
