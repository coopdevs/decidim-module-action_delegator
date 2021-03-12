# frozen_string_literal: true

require "spec_helper"

describe "Admin manages sum of weight consultation results", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:question) { create(:question, consultation: consultation) }
  let!(:response) { create(:response, question: question, title: { "ca" => "A" }) }

  let!(:other_user) { create(:user, :confirmed, organization: organization) }

  before do
    # Regular vote
    question.votes.create(author: user, response: response)
    # Vote of a user with membership
    question.votes.create(author: other_user, response: response)

    create(
      :authorization,
      :direct_verification,
      user: other_user,
      metadata: { membership_type: "consumer", membership_weight: 3 }
    )

    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when viewing a finished consultation with votes" do
    let(:consultation) { create(:consultation, :finished, :published_results, organization: organization) }

    it "shows total votes taking membership weight into account" do
      visit decidim_admin_action_delegator.consultation_results_sum_of_weights_path(consultation)

      within_table("results") do
        expect(find(".response-title")).to have_content("A")
        expect(find(".votes-count")).to have_content(4)
      end
    end

    it "enables exporting to CSV" do
    end
  end

  context "when viewing an unfinished consultation" do
    let!(:consultation) { create(:consultation, :active, :unpublished_results, organization: organization) }

    it "disables the export button" do
    end

    it "does not show any response" do
    end
  end
end
