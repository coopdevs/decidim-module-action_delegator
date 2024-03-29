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
               class_name: "Decidim::ActionDelegator::Delegation",
               dependent: :restrict_with_error
      has_many :ponderations,
               inverse_of: :setting,
               foreign_key: "decidim_action_delegator_setting_id",
               class_name: "Decidim::ActionDelegator::Ponderation",
               dependent: :restrict_with_error
      has_many :participants,
               inverse_of: :setting,
               foreign_key: "decidim_action_delegator_setting_id",
               class_name: "Decidim::ActionDelegator::Participant",
               dependent: :restrict_with_error

      validates :max_grants, presence: true
      validates :max_grants, numericality: { greater_than: 0 }
      validates :consultation, uniqueness: true

      enum authorization_method: { phone: 0, email: 1, both: 2 }, _prefix: :verify_with

      delegate :title, to: :consultation
      delegate :organization, to: :consultation

      default_scope { order(created_at: :desc) }

      def state
        @state ||= if consultation.end_voting_date < Time.zone.now
                     :closed
                   elsif consultation.start_voting_date <= Time.zone.now
                     :ongoing
                   else
                     :pending
                   end
      end

      def ongoing?
        state == :ongoing
      end

      def editable?
        state != :closed
      end

      def destroyable?
        participants.empty? && ponderations.empty? && delegations.empty?
      end

      def phone_required?
        verify_with_phone? || verify_with_both?
      end

      def email_required?
        verify_with_email? || verify_with_both?
      end
    end
  end
end
