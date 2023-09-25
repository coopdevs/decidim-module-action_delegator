# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class CreateParticipant < Decidim::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_participant

          broadcast(:ok, participant)
        end

        private

        attr_reader :form, :participant

        def create_participant
          @participant = Participant.create!(email: form.email,
                                             phone: form.phone,
                                             decidim_action_delegator_ponderation_id: form.decidim_action_delegator_ponderation_id,
                                             setting: form.setting)
        end
      end
    end
  end
end
