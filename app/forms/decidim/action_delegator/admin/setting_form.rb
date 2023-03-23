# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class SettingForm < Form
        mimic :setting

        attribute :max_grants, Integer, default: 1
        attribute :decidim_consultation_id, Integer
        attribute :verify_with_sms, Boolean
        attribute :phone_freezed, Boolean

        validate :consultation_uniqueness

        # TODO: validate consultation vote starting in the future
        def consultation_uniqueness
          errors.add(:decidim_consultation_id, :taken) if record.exists?(decidim_consultation_id: decidim_consultation_id)
        end

        def record
          Setting.where.not(id: id)
        end
      end
    end
  end
end
