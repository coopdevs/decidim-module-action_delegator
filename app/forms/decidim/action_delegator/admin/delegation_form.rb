# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      # A form object used to create a Delegation
      #
      class DelegationForm < Form
        mimic :delegation

        attribute :granter_id, Integer
        attribute :grantee_id, Integer

        attribute :granter_email, String
        attribute :grantee_email, String

        validate :granter_exists
        validate :grantee_exists

        def granter
          User.find_by(id: granter_id, organization: current_organization) || User.find_by(email: granter_email, organization: current_organization)
        end

        def grantee
          User.find_by(id: grantee_id, organization: current_organization) || User.find_by(email: grantee_email, organization: current_organization)
        end

        private

        def current_organization
          context&.current_organization
        end

        def granter_exists
          return if granter.present?

          errors.add :granter_email, I18n.t("decidim.action_delegator.admin.delegations.granter_missing")
        end

        def grantee_exists
          return if grantee.present?

          errors.add :grantee_email, I18n.t("decidim.action_delegator.admin.delegations.grantee_missing")
        end
      end
    end
  end
end
