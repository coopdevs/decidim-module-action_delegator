# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::ResponsesByMembership do
  subject { described_class.new(relation) }

  let(:relation) do
    relation = Decidim::Consultations::Response.joins(question: :consultation).where(question: question)
    Decidim::ActionDelegator::VotedWithPonderations.new(relation).query
  end

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }
  let(:question) { create(:question, consultation: consultation) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:other_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:response) { create(:response, question: question) }
  let(:setting) { create(:setting, consultation: consultation) }
  let(:ponderation1) { create(:ponderation, setting: setting, name: "foo", weight: 2) }
  let(:ponderation2) { create(:ponderation, setting: setting, name: "bar", weight: 3) }

  before do
    question.votes.create(author: user, response: response)
    question.votes.create(author: other_user, response: response)
  end

  describe "#query" do
    context "when users have the same ponderation" do
      let!(:participant1) { create(:participant, ponderation: ponderation1, decidim_user: user, setting: setting) }
      let!(:participant2) { create(:participant, ponderation: ponderation1, decidim_user: other_user, setting: setting) }

      it "returns response votes by ponderation in a single row" do
        result = subject.query

        expect(result.first.membership_type).to eq(ponderation1.name)
        expect(result.first.membership_weight).to eq(ponderation1.weight)
        expect(result.first.votes_count).to eq(2)
      end
    end

    context "when users have different ponderations" do
      let!(:participant1) { create(:participant, ponderation: ponderation1, decidim_user: user, setting: setting) }
      let!(:participant2) { create(:participant, ponderation: ponderation2, decidim_user: other_user, setting: setting) }

      it "returns response votes by ponderation in different rows" do
        result = subject.query

        expect(result.first.membership_type).to eq(ponderation2.name)
        expect(result.first.membership_weight).to eq(ponderation2.weight)
        expect(result.first.votes_count).to eq(1)

        expect(result.second.membership_type).to eq(ponderation1.name)
        expect(result.second.membership_weight).to eq(ponderation1.weight)
        expect(result.second.votes_count).to eq(1)
      end
    end

    context "when dome users don't have ponderation" do
      let!(:participant1) { create(:participant, ponderation: ponderation1, decidim_user: user, setting: setting) }

      it "returns response votes by ponderations in different rows" do
        result = subject.query

        expect(result.first.membership_type).to eq(ponderation1.name)
        expect(result.first.membership_weight).to eq(ponderation1.weight)
        expect(result.first.votes_count).to eq(1)

        expect(result.second.membership_type).to eq("(membership data not available)")
        expect(result.second.membership_weight).to eq(1)
        expect(result.second.votes_count).to eq(1)
      end
    end
  end
end
