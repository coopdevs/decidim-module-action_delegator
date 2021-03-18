# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe VotedWithDirectVerification do
      subject(:query_object) { described_class.new(relation) }

      let(:relation) { Decidim::Consultations::Response.where(question: question) }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
      let(:question) { create(:question, consultation: consultation) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:response) { create(:response, question: question) }

      before do
        question.votes.create(author: user, response: response)
        question.votes.create(author: other_user, response: response)
      end

      describe "#query" do
        context "when an author is authorized" do
          before do
            create(:authorization, :direct_verification, user: user)
            create(:authorization, name: "other_verifications", user: other_user)
          end

          it "includes only responses of those authorized with direct_verifications" do
            expect(query_object.query).to eq([response])
          end
        end

        context "when an author has no authorization" do
          it "includes their responses" do
            expect(query_object.query).to eq([response, response])
          end
        end

        context "when mixing authors with and without direct_verification" do
          before do
            create(:authorization, :direct_verification, user: user)
          end

          it "includes their responses" do
            expect(query_object.query).to eq([response, response])
          end
        end
      end
    end
  end
end
