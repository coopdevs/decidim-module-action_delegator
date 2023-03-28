# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verifications
      module DelegationsVerifier
        class AuthorizationsController < ApplicationController
          include Decidim::FormFactory
          include Decidim::Verifications::Renewable

          helper_method :authorization, :setting

          before_action do
            if setting.blank? || participants.find_by(email: current_user.email).blank?
              flash[:alert] = t(".not_in_census")
              redirect_back(fallback_location: decidim_verifications.authorizations_path)
            end
          end
          
          def new
            enforce_permission_to :create, :authorization, authorization: authorization

            @form = form(DelegationsVerifierForm).instance(setting: setting, participants: participants)
          end

          def create
            enforce_permission_to :create, :authorization, authorization: authorization

            @form = form(DelegationsVerifierForm).from_params(params, setting: setting, participants: participants)

            Decidim::Verifications::PerformAuthorizationStep.call(authorization, @form) do
              on(:ok) do
                flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.sms")
                authorization_method = Decidim::Verifications::Adapter.from_element(authorization.name)
                redirect_to authorization_method.resume_authorization_path(redirect_url: redirect_url)
              end
              on(:invalid) do
                flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.sms")
                render :new
              end
            end
          end

          def edit
            enforce_permission_to :update, :authorization, authorization: authorization

            @form = form(ConfirmationForm).from_params(params)
          end

          def update
            enforce_permission_to :update, :authorization, authorization: authorization

            @form = form(ConfirmationForm).from_params(params)

            ConfirmUserAuthorization.call(authorization, @form, session) do
              on(:ok) do
                flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.sms")

                if redirect_url
                  redirect_to redirect_url
                else
                  redirect_to decidim_verifications.authorizations_path
                end
              end

              on(:invalid) do
                flash.now[:alert] = t("authorizations.update.error", scope: "decidim.verifications.sms")
                render :edit
              end
            end
          end

          def destroy
            enforce_permission_to :destroy, :authorization, authorization: authorization

            authorization.destroy!
            flash[:notice] = t("authorizations.destroy.success", scope: "decidim.verifications.sms")

            redirect_to action: :new
          end

          private

          def authorization
            @authorization ||= Decidim::Authorization.find_or_initialize_by(
              user: current_user,
              name: "delegations_verifier"
            )
          end

          def participants
            @participants ||= Decidim::ActionDelegator::Participant.where(setting: setting)
          end

          def setting
            @setting ||= all_settings.first
          end

          def all_settings
            @all_settings ||= OrganizationSettings.new(current_user.organization).active
          end
        end
      end
    end
  end
end
