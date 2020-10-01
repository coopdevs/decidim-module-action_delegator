# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Settings, type: :model do
      subject { build(:setting) }

      it { is_expected.to belong_to(:consultation) }
      it { is_expected.to have_many(:delegations).dependent(:destroy) }

      it { is_expected.to validate_presence_of(:max_grants) }
      it { is_expected.to validate_numericality_of(:max_grants).is_greater_than(0) }
    end
  end
end
