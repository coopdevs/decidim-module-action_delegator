# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Participant, type: :model do
      subject { build(:participant, ponderation: ponderation, email: user.email) }

      let(:ponderation) { create(:ponderation) }
      let(:user) { create(:user) }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:setting) }

      it "belong_to a ponderation" do
        expect(subject.ponderation).to eq(ponderation)
      end

      it "has a related user" do
        expect(subject.user).to eq(user)
        expect(subject.user_name).to eq(user.name)
      end
    end
  end
end
