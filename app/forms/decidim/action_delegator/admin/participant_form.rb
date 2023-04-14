# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ParticipantForm < Form
        mimic :participant

        attribute :email, String
        attribute :phone, String
        attribute :decidim_action_delegator_ponderation_id, Integer
        attribute :weight

        validates :email, presence: true, if: ->(form) { form.authorization_method.in? %w(email both) }
        validates :phone, presence: true, if: ->(form) { form.authorization_method.in? %w(phone both) }
        validate :ponderation_belongs_to_setting

        # When there's a phone number, sanitize it allowing only numbers and +.
        def phone
          return unless super

          super.gsub(/[^+0-9]/, "")
        end

        def setting
          @setting ||= context[:setting]
        end

        def authorization_method
          @authorization_method ||= setting&.authorization_method
        end

        private

        def ponderation_belongs_to_setting
          return if decidim_action_delegator_ponderation_id.blank?
          return if setting.ponderations.where(id: decidim_action_delegator_ponderation_id).any?

          errors.add(:decidim_action_delegator_ponderation_id, :invalid)
        end
      end
    end
  end
end
