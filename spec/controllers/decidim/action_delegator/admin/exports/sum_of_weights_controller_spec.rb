# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    module Admin
      describe Exports::SumOfWeightsController, type: :controller do
        routes { Decidim::ActionDelegator::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user
        end

        describe "#create" do
          it "authorizes the action" do
            expect(controller).to receive(:allowed_to?)
              .with(:export_consultation_results, :consultation, consultation: consultation)

            post :create, params: { consultation_slug: consultation.slug }
          end

          it "enqueues a ExportConsultationResultsJob" do
            expect(ExportConsultationResultsJob).to receive(:perform_later)
              .with(user, consultation, "sum_of_weights")

            post :create, params: { consultation_slug: consultation.slug }
          end

          it "redirects back" do
            request.env["HTTP_REFERER"] = "referer"
            post :create, params: { consultation_slug: consultation.slug }

            expect(response).to redirect_to("referer")
          end

          it "returns a flash notice" do
            post :create, params: { consultation_slug: consultation.slug }
            expect(flash[:notice]).to eq(I18n.t("decidim.admin.exports.notice"))
          end
        end
      end
    end
  end
end
