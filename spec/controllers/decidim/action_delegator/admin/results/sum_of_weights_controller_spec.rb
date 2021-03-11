# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::Results::SumOfWeightsController, type: :controller do
  routes { Decidim::ActionDelegator::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user
  end

  describe "#index" do
    it "authorizes the action" do
      expect(controller).to receive(:allowed_to?).with(:read, :consultation, anything)
      get :index, params: { consultation_slug: consultation.slug }
    end

    it "renders decidim/admin/consultation layout" do
      get :index, params: { consultation_slug: consultation.slug }
      expect(response).to render_template("layouts/decidim/admin/consultation")
    end
  end
end
