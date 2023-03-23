# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class CreatePonderation < Rectify::Command
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

          create_ponderation

          broadcast(:ok, ponderation)
        end

        private

        attr_reader :form, :ponderation

        def create_ponderation
          @ponderation = Ponderation.create!(name: form.name, weight: form.weight, setting: form.setting)
        end
      end
    end
  end
end
