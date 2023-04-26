# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ActionDelegator::Admin::InviteParticipantsJob, type: :job do
  let(:organization) { create(:organization) }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:consultation) { create(:consultation) }
  let!(:participants) { create_list(:participant, 3, setting: current_setting) }

  it "invites participants" do
    participants.each do |participant|
      expect { described_class.perform_later(participant, organization) }.not_to raise_error
    end
  end
end
