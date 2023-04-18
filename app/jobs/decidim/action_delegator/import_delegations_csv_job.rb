# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ImportDelegationsCsvJob < ApplicationJob
      queue_as :default

      def perform(granter_email, grantee_email, current_user, current_setting)
        return if granter_email.blank? || grantee_email.blank?

        params = {
          granter_id: Decidim::User.find_by(email: granter_email).id,
          grantee_id: Decidim::User.find_by(email: grantee_email).id
        }

        form = ::Decidim::ActionDelegator::Admin::DelegationForm.from_params(params)

        Decidim::ActionDelegator::Admin::CreateDelegation.call(form, current_user, current_setting)
      end
    end
  end
end
