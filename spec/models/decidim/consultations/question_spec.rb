# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    describe Question do
      subject { question }

      let(:consultation) { create :consultation, :published, :active }
      let(:question) { create :question, consultation: consultation }
      let(:response) { create :response, question: question }
      let!(:vote) { create :vote, question: question, response: response }

      it { is_expected.to be_publishable_results }

      context "when mod is not enabled" do
        before do
          allow(Decidim::ActionDelegator).to receive(:admin_preview_results).and_return(false)
        end

        it { is_expected.not_to be_publishable_results }
      end
    end
  end
end
