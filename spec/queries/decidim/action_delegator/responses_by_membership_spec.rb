# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::ResponsesByMembership do
  subject { described_class.new(relation) }

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

    create(:authorization, :direct_verification, user: user, metadata: auth_metadata)
    create(:authorization, :direct_verification, user: other_user, metadata: other_auth_metadata)
  end

  describe "#query" do
    context "when users have the same membership_weight" do
      let(:auth_metadata) { { membership_type: "producer", membership_weight: 2 } }
      let(:other_auth_metadata) { { membership_type: "producer", membership_weight: 2 } }

      it "returns response votes by membership's type and weight in a single row" do
        result = subject.query

        expect(result.first.membership_type).to eq("producer")
        expect(result.first.membership_weight).to eq("2")
        expect(result.first.votes_count).to eq(2)
      end
    end

    context "when users have different membership_weight" do
      let(:auth_metadata) { { membership_type: "producer", membership_weight: 2 } }
      let(:other_auth_metadata) { { membership_type: "producer", membership_weight: 1 } }

      it "returns response votes by membership's type in different rows" do
        result = subject.query

        expect(result.first.membership_type).to eq("producer")
        expect(result.first.membership_weight).to eq("2")
        expect(result.first.votes_count).to eq(1)

        expect(result.second.membership_type).to eq("producer")
        expect(result.second.membership_weight).to eq("1")
        expect(result.second.votes_count).to eq(1)
      end
    end

    context "when users have different membership_type" do
      let(:auth_metadata) { { membership_type: "producer", membership_weight: 2 } }
      let(:other_auth_metadata) { { membership_type: "consumer", membership_weight: 2 } }

      it "returns response votes by membership's type in different rows" do
        result = subject.query

        expect(result.first.membership_type).to eq("consumer")
        expect(result.first.membership_weight).to eq("2")
        expect(result.first.votes_count).to eq(1)

        expect(result.second.membership_type).to eq("producer")
        expect(result.second.membership_weight).to eq("2")
        expect(result.second.votes_count).to eq(1)
      end
    end

    context "when users have multiple authorizations" do
      let(:auth_metadata) { { membership_type: "producer", membership_weight: 2 } }
      let(:other_auth_metadata) { { membership_type: "consumer", membership_weight: 2 } }

      before do
        create(:authorization, user: user, metadata: {})
      end

      it "only considers direct_verifications authorizations" do
        result = subject.query

        expect(result.first.membership_type).to eq("consumer")
        expect(result.first.membership_weight).to eq("2")
        expect(result.first.votes_count).to eq(1)

        expect(result.second.membership_type).to eq("producer")
        expect(result.second.membership_weight).to eq("2")
        expect(result.second.votes_count).to eq(1)

        expect(result.third).to be_nil
      end
    end
  end
end
