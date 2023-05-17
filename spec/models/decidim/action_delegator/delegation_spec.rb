# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Delegation, type: :model do
      subject { build(:delegation) }

      it { is_expected.to belong_to(:setting) }
      it { is_expected.to be_valid }
      it { is_expected.not_to be_voted }

      describe ".granted_to?" do
        subject { delegation }

        let!(:delegation) { create(:delegation, setting: setting) }
        let(:user) { create(:user) }
        let(:consultation) { create(:consultation, :active, organization: user.organization) }
        let(:question) { create(:question, consultation: consultation) }
        let(:response) { create(:response, question: question) }
        let!(:vote) { create(:vote, question: question, response: response, author: user) }
        let(:setting) { create(:setting, consultation: consultation) }

        shared_examples "can be destroyed" do
          it { is_expected.not_to be_voted }

          it "can be destroyed" do
            expect { subject.destroy }.to change(described_class, :count).by(-1)
          end
        end

        shared_examples "cannot be destroyed" do
          it { is_expected.to be_voted }

          it "cannot be destroyed" do
            expect { subject.destroy }.not_to change(described_class, :count)
          end
        end

        it_behaves_like "can be destroyed"

        context "when there is no delegation granted to user for the given consultation" do
          it "returns false" do
            expect(described_class.granted_to?(user, consultation)).to eq(false)
          end

          it_behaves_like "can be destroyed"
        end

        context "when there are delegations granted to user for the given consultation" do
          let!(:delegation) { create(:delegation, setting: setting, grantee: user) }

          it "returns true" do
            expect(described_class.granted_to?(user, consultation)).to eq(true)
          end

          it_behaves_like "can be destroyed"

          context "and granter has voted" do
            let!(:vote) { create(:vote, question: question, response: response, author: delegation.granter) }

            it_behaves_like "can be destroyed"

            context "and grantee has voted in behave of the granter" do
              it_behaves_like "cannot be destroyed"
            end
          end
        end
      end
    end
  end
end
