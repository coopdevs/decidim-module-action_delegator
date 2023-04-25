# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class InviteParticipantsJob < ApplicationJob
        queue_as :invite_participants

        def perform(participant, organization)
          form = InvitationParticipantForm.new(
            name: participant.email.split("@").first&.gsub(/\W/, ""),
            email: participant.email.downcase,
            organization: organization,
            admin: false
          )

          Decidim::InviteUser.call(form)
        end
      end
    end
  end
end
