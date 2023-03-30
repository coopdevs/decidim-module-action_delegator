# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Ponderation, type: :model do
      subject { build(:participant) }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:setting) }
    end
  end
end
