# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe VotedWithPonderations do
      subject(:query_object) { described_class.new(relation) }

      let(:relation) { Decidim::Consultations::Response.where(question: question).joins(question: :consultation) }

      let(:organization) { create(:organization) }
      let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
      let(:question) { create(:question, consultation: consultation) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:response) { create(:response, question: question) }
      let(:setting) { create(:setting, consultation: consultation) }
      let(:ponderation) { create(:ponderation, setting: setting) }
      let(:other_consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
      let(:other_setting) { create(:setting, consultation: other_consultation) }
      let(:other_ponderation) { create(:ponderation, setting: other_setting) }

      let(:responses) { [response, response] }
      let(:attribute_ok) do
        { "name" => ponderation.name, "weight" => ponderation.weight, "id" => response.id }
      end
      let(:attribute_nil) do
        { "name" => nil, "weight" => nil, "id" => response.id }
      end

      before do
        question.votes.create(author: user, response: response)
        question.votes.create(author: other_user, response: response)
        create(:participant, setting: other_setting, ponderation: other_ponderation, decidim_user: other_user)
      end

      describe "#query" do
        context "when an authors are ponderated" do
          before do
            create(:participant, setting: setting, ponderation: ponderation, decidim_user: user)
            create(:participant, setting: setting, ponderation: ponderation, decidim_user: other_user)
          end

          it "all the weights of the current setting" do
            expect(query_object.query).to eq(responses)
            expect(query_object.query.select(:name, :weight, :id).map(&:attributes)).to eq([attribute_ok, attribute_ok])
          end
        end

        context "when an author has no ponderations" do
          it "includes their responses" do
            expect(query_object.query).to eq(responses)
            expect(query_object.query.select(:name, :weight, :id).map(&:attributes)).to eq([attribute_nil, attribute_nil])
          end
        end

        context "when mixing authors with and without ponderations" do
          before do
            create(:participant, setting: setting, ponderation: ponderation, decidim_user: user)
          end

          it "includes their responses" do
            expect(query_object.query).to eq(responses)
            expect(query_object.query.select(:name, :weight, :id).map(&:attributes)).to eq([attribute_ok, attribute_nil])
          end
        end
      end
    end
  end
end
