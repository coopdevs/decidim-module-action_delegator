# frozen_string_literal: true

require "decidim/action_delegator/verifications/delegations_authorizer"
require "decidim/action_delegator/verifications/delegations_verifier"
require "decidim/action_delegator/admin"
require "decidim/action_delegator/admin_engine"
require "decidim/action_delegator/engine"

module Decidim
  # This namespace holds the logic of the `ActionDelegator` module
  module ActionDelegator
    include ActiveSupport::Configurable

    # this is the SmsGateway provided by this module
    # Note that it will be ignored if you provide your own SmsGateway in Decidm.sms_gateway_service
    config_accessor :sms_gateway_service do
      "Decidim::ActionDelegator::SmsGateway"
    end

    # The default expiration time for the integrated authorization
    # if zero, the authorization won't be registered
    config_accessor :authorization_expiration_time do
      3.months
    end

    # Put this to false if you don't want to allow administrators to invite users not registered
    # in the platform when uploading a census (inviting users without permission can be a GDPR offense).
    config_accessor :allow_to_invite_users do
      true
    end

    # used for comparing phone numbers from a census list and the ones introduced by the user
    # the phone number will be normalized before comparing it so, for instance,
    # if you have a census list with  +34 666 666 666 and the user introduces 0034666666666 or 666666666, they will be considered the same
    # can be empty or null if yo don't want to check different combinations of prefixes
    config_accessor :phone_prefixes do
      %w(+34 0034 34)
    end

    # The regex for validating phone numbers
    config_accessor :phone_regex do
      /^\d{6,15}$/ # 6 to 15 digits
    end

    # Consultations has an annoying and totally useless deprecation warning
    # This plugin removes it by default.
    # If you want to keep it, you can set this config to false
    config_accessor :remove_consultation_deprecation_warning do
      true
    end

    # In a consultation the highlighted questions are duplicated in the list of regular questions
    # this maintains the highlighted questions in the highlighted list and removes them from the regular list
    config_accessor :remove_duplicated_highlighted_questions do
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
