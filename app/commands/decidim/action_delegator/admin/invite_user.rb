# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class InviteUser < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # participant  - A participant object.
        def initialize(form, participant)
          @form = form
          @participant = participant
        end

        # Executes the command. Broadcasts these events:
        # - :ok when everything is valid.
        # - :invalid if the handler wasn't valid and we couldn't proceed.
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            invite_participant
          end

          broadcast(:ok)
        end

        private

        attr_reader :user, :form, :participant

        def invite_participant
          @user = User.invite!(form_params)
          @user.invited_by = form.current_user
          @participant.decidim_user_id = @user.id
        end

        def form_params
          {
            email: form.email.downcase,
            name: Decidim::User.nicknamize(form.email.downcase, organization: form.current_user.organization),
            nickname: Decidim::User.nicknamize(form.email.downcase, organization: form.current_user.organization),
            organization: form.current_organization,
            admin: false,
            invited_by: form.current_user,
            invitation_instructions: "invite_participant"
          }
        end
      end
    end
  end
end
