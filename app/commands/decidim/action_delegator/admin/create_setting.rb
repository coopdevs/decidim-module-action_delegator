# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class CreateSetting < Rectify::Command
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

          create_setting

          broadcast(:ok, setting)
        end

        private

        attr_reader :form, :setting

        def create_setting
          @setting = Setting.create!(max_grants: form.max_grants,
                                     authorization_method: form.authorization_method,
                                     decidim_consultation_id: form.decidim_consultation_id)
        end
      end
    end
  end
end
