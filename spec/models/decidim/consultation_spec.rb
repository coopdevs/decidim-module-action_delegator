# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Consultation do
    subject { consultation }

    let(:organization) { create(:organization) }
    let(:consultation) { create(:consultation, organization: organization) }
    let(:question) { create(:question, consultation: consultation) }
    let(:setting) { create(:setting, consultation: consultation) }

    let(:granter) { create(:user, organization: organization) }
    let!(:delegation) { create(:delegation, setting: setting, granter: granter) }
    let!(:delegated_vote) { create(:vote, author: granter, question: question) }

    describe ".total_delegates" do
      it "total votes count is correct" do
        expect(consultation.total_delegates).to eq(1)
      end
    end
  end
end
