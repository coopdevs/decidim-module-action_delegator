# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class CreateSetting < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        def initialize(form, selected_setting)
          @form = form
          @selected_setting = selected_setting
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_setting

          broadcast(:ok, setting)
        end

        private

        attr_reader :form, :setting

        def create_setting
          selected = selected_setting || Setting.new(ponderations: [], participants: [])

          created_setting = Setting.new(
            max_grants: form.max_grants,
            authorization_method: form.authorization_method,
            decidim_consultation_id: form.decidim_consultation_id
          )

          selected.ponderations.each do |ponderation|
            created_setting.ponderations << ponderation.dup
          end

          selected.participants.each do |participant|
            created_setting.participants << participant.dup
          end

          @setting = created_setting.save!
        end
      end
    end
  end
end
