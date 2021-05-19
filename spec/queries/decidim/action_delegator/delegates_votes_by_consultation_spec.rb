# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::DelegatesVotesByConsultation do
  subject { described_class.new(consultation) }

  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let(:question) { create(:question, consultation: consultation) }

  let(:granter) { create(:user, organization: organization) }
  let(:another_granter) { create(:user, organization: organization) }

  describe "#query" do
    context "when there are delegations for the specified consultation" do
      let(:setting) { create(:setting, consultation: consultation) }

      before do
        create(:delegation, setting: setting, granter: granter)
        create(:vote, author: granter, question: question)

        create(:delegation, setting: setting, granter: another_granter)
        create(:vote, author: another_granter, question: question)
      end

      it "returns the count of delegated votes" do
        expect(subject.query).to eq(2)
      end
    end

    context "when there are delegations for other consultations" do
      let(:other_consultation) { create(:consultation, organization: organization) }
      let(:other_setting) { create(:setting, consultation: other_consultation) }

      before do
        create(:delegation, setting: other_setting, granter: granter)
        create(:vote, author: granter, question: question)

        create(:delegation, setting: other_setting, granter: another_granter)
        create(:vote, author: another_granter, question: question)
      end

      it "returns the count of delegated votes" do
        expect(subject.query).to eq(0)
      end
    end
  end
end
