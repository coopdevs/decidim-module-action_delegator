# frozen_string_literal: true

require "decidim/action_delegator/admin"
require "decidim/action_delegator/admin_engine"
require "decidim/action_delegator/engine"

module Decidim
  # This namespace holds the logic of the `ActionDelegator` module
  module ActionDelegator
    include ActiveSupport::Configurable

    # Consultations has an annoying and totally useless deprecation warning
    # This plugin removes it by default.
    # If you want to keep it, you can set this config to false
    config_accessor :remove_consultation_deprecation_warning do
      true
    end
  end
end

# We register 2 global engines to handle logic unrelated to participatory spaces or components

# User space engine, used mostly in the context of the user profile to let the users
# manage their delegations
Decidim.register_global_engine(
  :decidim_action_delegator, # this is the name of the global method to access engine routes
  ::Decidim::ActionDelegator::Engine,
  at: "/action_delegator"
)

# Admin side of the delegations management. Admins can overlook all delegations and
# create their own
Decidim.register_global_engine(
  :decidim_admin_action_delegator,
  ::Decidim::ActionDelegator::AdminEngine,
  at: "/admin/action_delegator"
)
