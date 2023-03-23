# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class UpdateParticipant < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        def initialize(form, participant)
          @form = form
          @participant = participant
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_participant

          broadcast(:ok, participant)
        end

        private

        attr_reader :form, :participant

        def update_participant
          participant.email = form.email
          participant.phone = form.phone
          participant.decidim_action_delegator_ponderation_id = form.decidim_action_delegator_ponderation_id
          participant.save!
        end
      end
    end
  end
end
