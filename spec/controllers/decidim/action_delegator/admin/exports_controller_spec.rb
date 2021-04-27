# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Admin::Consultations::ExportsController, type: :controller do
      routes { Decidim::ActionDelegator::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }

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
          expect(ExportConsultationResultsJob).to receive(:perform_later).with(user, consultation)
          post :create, params: { consultation_slug: consultation.slug }
        end
      end
    end
  end
end
