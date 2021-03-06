# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # Contains the delegation settings of a consultation. Rather than a single attribute here
    # a setting is the record itself: a bunch of configuration values.
    class Setting < ApplicationRecord
      self.table_name = "decidim_action_delegator_settings"

      belongs_to :consultation,
                 foreign_key: "decidim_consultation_id",
                 class_name: "Decidim::Consultation"
      has_many :delegations,
               inverse_of: :setting,
               foreign_key: "decidim_action_delegator_setting_id",
               dependent: :destroy

      validates :max_grants, presence: true
      validates :max_grants, numericality: { greater_than: 0 }
    end
  end
end
