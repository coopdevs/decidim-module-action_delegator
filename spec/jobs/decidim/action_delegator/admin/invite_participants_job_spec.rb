# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ActionDelegator::Admin::InviteParticipantsJob, type: :job do
  let(:organization) { create(:organization) }
  let(:current_setting) { create(:setting, consultation: consultation) }
  let(:consultation) { create(:consultation) }
  let(:participants) { create_list(:participant, 3, setting: current_setting) }

  it "does not raise error" do
    expect do
      participants.each do |participant|
        described_class.perform_now(participant, organization)
      end
    end.not_to raise_error
  end

  it "sends an email to the invited participant" do
    perform_enqueued_jobs do
      described_class.perform_now(participants.first, organization)
    end

    email = last_email
    expect(email.subject).to include("Invitation instructions")
    expect(email.body.encoded).to match("Accept invitation")
  end

  context "when participants are registered" do
    let(:user) { create(:user, organization: organization) }
    let(:participant) { create(:participant, setting: current_setting, decidim_user_id: user.id) }

    it "does not send invitiations" do
      expect { described_class.perform_later(participant, organization) }.not_to raise_error

      expect(last_email).to be_nil
    end
  end
end
