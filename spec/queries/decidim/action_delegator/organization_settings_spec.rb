# frozen_string_literal: true

require "spec_helper"

module Decidim::ActionDelegator
  describe OrganizationSettings do
    subject { described_class.new(organization) }

    let(:organization) { create(:organization) }
    let(:consultation) { create(:consultation, organization: organization) }

    describe "#query" do
      context "when the organization has a setting" do
        let!(:setting) { create(:setting, consultation: consultation) }
        let!(:other_setting) { create(:setting) }

        it "returns settings of the specified organization only" do
          expect(subject.query).to match_array([setting])
        end
      end

      context "when the organization has no settings" do
        it "returns an empty ActiveRecord::Relation" do
          expect(subject.query).to be_empty
        end
      end
    end
  end
end
