# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class CreateDelegation < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # delegated_by - The user performing the operation
        def initialize(form, performed_by, current_setting)
          @form = form
          @performed_by = performed_by
          @current_setting = current_setting
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid? || current_setting.nil?
          return broadcast(:above_max_grants) if above_max_grants?

          create_delegation

          return broadcast(:invalid) if delegation.invalid?
          broadcast(:ok)
        end

        private

        attr_reader :form, :performed_by, :current_setting, :delegation

        def above_max_grants?
          grants_count >= current_setting.max_grants
        end

        def grants_count
          SettingDelegations.new(current_setting).query
                            .where(grantee_id: form.grantee_id)
                            .count
        end

        def create_delegation
          @delegation = Delegation.create(form.attributes.merge(setting: current_setting))
        end
      end
    end
  end
end
