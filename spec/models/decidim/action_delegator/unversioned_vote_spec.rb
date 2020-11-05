# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe UnversionedVote do
      subject(:unversioned_vote) { described_class.new(vote) }

      let(:vote) { build(:vote) }

      it "disables PaperTrail", versioning: true do
        subject.save

        expect(unversioned_vote.versions).to be_empty
      end
    end
  end
end
