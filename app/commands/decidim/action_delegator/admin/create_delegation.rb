# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class CreateDelegation < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # delegated_by - The user performing the operation
        def initialize(form, performed_by)
          @form = form
          @performed_by = performed_by
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || self_delegate?

          create_delegation!

          broadcast(:ok)
        end

        private

        attr_reader :form, :performed_by

        def self_delegate?
          return false unless performed_by.id == form.grantee_id

          form.errors.add(:grantee_id, :self_delegate)
          true
        end

        def create_delegation!
          Delegation.create!(form.attributes)
        end
      end
    end
  end
end
