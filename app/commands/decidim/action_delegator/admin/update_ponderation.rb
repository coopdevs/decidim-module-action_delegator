# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class UpdatePonderation < Decidim::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        def initialize(form, ponderation)
          @form = form
          @ponderation = ponderation
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_ponderation

          broadcast(:ok, ponderation)
        end

        private

        attr_reader :form, :ponderation

        def update_ponderation
          ponderation.name = form.name
          ponderation.weight = form.weight
          ponderation.save!
        end
      end
    end
  end
end
