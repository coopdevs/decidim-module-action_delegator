# frozen_string_literal: true

require "spec_helper"

describe Decidim::ActionDelegator::Admin::ImportDelegationsCsv do
  subject { described_class.new(form, current_user, current_setting) }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, organization: organization) }
  let(:current_setting) { create(:setting, max_grants: 1) }
  let(:file) { File.new Decidim::Dev.asset("import_participatory_space_private_users.csv") }
  let(:validity) { true }

  let(:form) do
    double(
      current_user: current_user,
      current_setting: current_setting,
      file: file,
      valid?: validity
    )
  end

  context "when the form is not valid" do
    let(:validity) { false }

    it "broadcasts invalid" do
      expect(subject.call).to broadcast(:invalid)
    end

    it "does not enqueue any job" do
      expect(Decidim::ActionDelegator::ImportDelegationsCsvJob).not_to receive(:perform_later)

      subject.call
    end
  end

  it "broadcasts ok" do
    expect(subject.call).to broadcast(:ok)
  end

  it "enqueues a job for each present value" do
    expect(Decidim::ActionDelegator::ImportDelegationsCsvJob).to receive(:perform_later).twice.with(kind_of(String), kind_of(String), current_user, current_setting)

    subject.call
  end
end
