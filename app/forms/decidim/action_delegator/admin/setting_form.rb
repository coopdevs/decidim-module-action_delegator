# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class SettingForm < Form
        mimic :setting

        attribute :max_grants, Integer
        attribute :decidim_consultation_id, Integer
        attribute :authorization_method, String
        attribute :source_consultation_id, Integer

        validates :max_grants, :decidim_consultation_id, presence: true
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
