# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Ponderation, type: :model do
      subject { build(:ponderation) }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:setting) }

      it "has an automatic title" do
        expect(subject.title).to eq(" #{subject.name} (x#{subject.weight})")
      end
    end
  end
end
