# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ActionDelegator
    describe Participant, type: :model do
      subject { build(:participant, ponderation: ponderation, email: email, phone: phone, setting: setting) }

      let(:setting) { create(:setting, authorization_method: authorization_method) }
      let(:organization) { setting.organization }
      let(:authorization_method) { :email }
      let(:ponderation) { create(:ponderation) }
      let(:user) { create(:user) }
      let(:email) { user.email }
      let(:phone) { "34123456" }

      it { is_expected.to be_valid }
      it { is_expected.to belong_to(:setting) }

      it "belong_to a ponderation" do
        expect(subject.ponderation).to eq(ponderation)
      end

      it "has a related user" do
        expect(subject.user).to eq(user)
        expect(subject.user_name).to eq(user.name)
      end

      context "when verification method is phone" do
        let(:authorization_method) { :phone }
        let(:email) { nil }

        it { is_expected.to be_valid }

        it "has no user" do
          expect(subject.user).to be_nil
        end

        context "and an authorization exists" do
          let(:user_phone) { phone }
          let!(:authorization) { create(:authorization, user: user, name: "delegations_verifier", metadata: { phone: user_phone }, unique_id: uniq_id) }
          let(:uniq_id) { Digest::MD5.hexdigest("#{user_phone}-#{organization.id}-#{Digest::MD5.hexdigest(Rails.application.secrets.secret_key_base)}") }

          it "has a related user" do
            expect(subject.user).to eq(user)
            expect(subject.user_name).to eq(user.name)
          end

          context "and authorization number has different prefixes" do
            ["", "+34", "0034", "34"].each do |prefix|
              let(:user_phone) { "#{prefix}#{phone}" }

              it "has a related user" do
                expect(subject.user).to eq(user)
                expect(subject.user_name).to eq(user.name)
              end
            end
          end

          context "and participant number has different prefixes" do
            let(:user_phone) { "34123456" }

            ["", "+34", "0034", "34"].each do |prefix|
              let(:phone) { "#{prefix}#{user_phone}" }

              it "has a related user" do
                expect(subject.user).to eq(user)
                expect(subject.user_name).to eq(user.name)
              end
            end
          end
        end
      end
    end
  end
end
