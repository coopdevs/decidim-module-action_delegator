# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe Question do
      subject { question }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, organization: organization) }
      let(:setting) { create(:setting, consultation: consultation) }
      let(:question) { create(:question, consultation: consultation) }

      let(:granter) { create(:user, organization: organization) }
      let!(:delegation) { create(:delegation, setting: setting, granter: granter) }
      let!(:delegated_vote) { create(:vote, author: granter, question: question) }

      describe ".total_delegates" do
        it "total votes count is correct" do
          expect(question.total_delegates).to eq(1)
        end
      end
    end
  end
end
