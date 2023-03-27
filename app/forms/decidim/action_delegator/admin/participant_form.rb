# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ParticipantForm < Form
        mimic :participant

        attribute :email, String
        attribute :phone, String
        attribute :decidim_action_delegator_ponderation_id, Integer

        validates :email, presence: true
        validate :ponderation_belongs_to_setting

        private

        def ponderation_belongs_to_setting
          return if decidim_action_delegator_ponderation_id.blank?
          return if setting.ponderations.where(id: decidim_action_delegator_ponderation_id).any?

          errors.add(:decidim_action_delegator_ponderation_id, :invalid)
        end

        def setting
          @setting ||= context[:setting]
        end
      end
    end
  end
end
