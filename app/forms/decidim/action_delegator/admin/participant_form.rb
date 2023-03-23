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

        # TODO: validate ponderation belonging to the same setting
        def setting
          @setting ||= context[:setting]
        end
      end
    end
  end
end
