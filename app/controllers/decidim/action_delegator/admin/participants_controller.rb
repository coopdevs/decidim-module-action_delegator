# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ParticipantsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission
        include Decidim::Paginable

        helper ::Decidim::ActionDelegator::Admin::DelegationHelper
        helper_method :current_setting, :participants

        layout "decidim/action_delegator/admin/delegations"

        def index
          enforce_permission_to :index, :participant
        end

        def new
          enforce_permission_to :create, :participant

          @form = form(ParticipantForm).instance
        end

        def create
          enforce_permission_to :create, :participant

          @form = ParticipantForm.from_params(params).with_context(setting: current_setting)

          CreateParticipant.call(@form) do
            on(:ok) do
              notice = I18n.t("participants.create.success", scope: "decidim.action_delegator.admin")
              redirect_to setting_participants_path(current_setting), notice: notice
            end

            on(:invalid) do |_error|
              flash.now[:error] = I18n.t("participants.create.error", scope: "decidim.action_delegator.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :participant

          @form = form(ParticipantForm).from_model(participant)
        end

        def update
          enforce_permission_to :update, :participant

          @form = ParticipantForm.from_params(params).with_context(setting: current_setting)
          UpdateParticipant.call(@form, participant) do
            on(:ok) do
              notice = I18n.t("participants.update.success", scope: "decidim.action_delegator.admin")
              redirect_to setting_participants_path(current_setting), notice: notice
            end

            on(:invalid) do |_error|
              flash.now[:error] = I18n.t("participants.update.error", scope: "decidim.action_delegator.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :participant, resource: participant

          if participant.destroy
            notice = I18n.t("participants.destroy.success", scope: "decidim.action_delegator.admin")
            redirect_to setting_participants_path(current_setting), notice: notice
          else
            error = I18n.t("participants.destroy.error", scope: "decidim.action_delegator.admin")
            redirect_to setting_participants_path(current_setting), flash: { error: error }
          end
        end

        private

        def participant
          @participant ||= collection.find_by(id: params[:id])
        end

        def participants
          @participants ||= paginate(collection)
        end

        def collection
          @collection ||= current_setting.participants
        end

        def current_setting
          @current_setting ||= organization_settings.find_by(id: params[:setting_id])
        end

        def organization_settings
          ActionDelegator::OrganizationSettings.new(current_organization).query
        end
      end
    end
  end
end
