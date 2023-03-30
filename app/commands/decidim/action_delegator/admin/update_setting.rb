# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class UpdateSetting < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        def initialize(form, setting)
          @form = form
          @setting = setting
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_setting

          broadcast(:ok, setting)
        end

        private

        attr_reader :form, :setting

        def update_setting
          setting.max_grants = form.max_grants
          setting.decidim_consultation_id = form.decidim_consultation_id
          setting.authorization_method = form.authorization_method
          setting.save!
        end
      end
    end
  end
end
