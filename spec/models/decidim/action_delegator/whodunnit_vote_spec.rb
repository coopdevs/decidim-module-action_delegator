# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::WhodunnitVote do
  describe "#save" do
    subject { described_class.new(vote, user) }

    let(:vote) { build(:vote) }
    let(:user) { create(:user) }

    it "sets PaperTrail's whodunnit" do
      expect(PaperTrail).to receive(:request).with(whodunnit: user.id).and_yield
      subject.save
    end
  end
end
