# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class InvitationForm < Form
        mimic :invitation

        attribute :name, String
        attribute :email, String
        attribute :nickname, String
        attribute :organization, Decidim::Organization
        attribute :admin, Boolean, default: false
        attribute :invited_by, Decidim::User
        attribute :invitation_instructions, String

        validates :email, presence: true
        validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
        validate :email_uniqueness

        private

        def email_uniqueness
          return unless organization
          return unless organization.users.where(email: email).any?

          errors.add(:email, :taken)
        end
      end
    end
  end
end
