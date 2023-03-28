# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verifications
      class DelegationsAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        def authorize
          status = super
          return status unless status == [:ok, {}]
          # byebug

          return [:ok, {}] if belongs_to_consultation? && user_in_census?

          [:unauthorized, { extra_explanation: extra_explanations }]
        end

        private

        def belongs_to_consultation?
          return unless setting&.consultation

          setting.consultation == consultation
        end

        def user_in_census?
          return unless setting&.participants

          setting.participants.exists?(census_params)
        end

        def census_params
          return @census_params if @census_params

          @census_params = { email: authorization.user.email }
          @census_params[:phone] = authorization.metadata["phone"] if setting.verify_with_sms? && setting.phone_freezed?
          @census_params
        end

        def extra_explanations
          return @extra_explanations if @extra_explanations

          unless setting
            return [{
              key: "no_setting",
              params: { scope: "decidim.action_delegator.delegations_authorizer" }
            }]
          end

          @extra_explanations = [{
            key: "not_in_census",
            params: { scope: "decidim.action_delegator.delegations_authorizer" }
          }]

          @extra_explanations << {
            key: "email",
            params: { scope: "decidim.action_delegator.delegations_authorizer", email: authorization.user.email }
          }

          if setting.verify_with_sms? && setting.phone_freezed?
            @extra_explanations << {
              key: "phone",
              params: { scope: "decidim.action_delegator.delegations_authorizer", phone: authorization.metadata["phone"] || "---" }
            }
          end
          @extra_explanations
        end

        def setting
          @setting ||= Decidim::ActionDelegator::Setting.find_by(consultation: consultation)
        end

        def consultation
          @consultation ||= begin
            component.participatory_space if component&.participatory_space.is_a?(Decidim::Consultation)
          end
        end

        def manifest
          @manifest ||= Decidim::Verifications.find_workflow_manifest(authorization&.name)
        end
      end
    end
  end
end
