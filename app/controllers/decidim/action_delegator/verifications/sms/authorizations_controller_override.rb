# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verifications
      module Sms
        module AuthorizationsControllerOverride
          extend ActiveSupport::Concern

          included do
            def new
              enforce_permission_to :create, :authorization, authorization: authorization

              flash.now[:error] = I18n.t("decidim.action_delegator.authorizations.new.missing_phone_error") unless direct_authorization && membership_phone

              @form = Decidim::Verifications::Sms::MobilePhoneForm.new mobile_phone_number: membership_phone
            end

            private

            def direct_authorization
              @direct_authorization ||= Decidim::Authorization.find_by(
                user: current_user,
                name: "direct_verifications"
              )
            end

            def membership_phone
              return nil unless direct_authorization

              direct_authorization.metadata["membership_phone"]
            end
          end
        end
      end
    end
  end
end
