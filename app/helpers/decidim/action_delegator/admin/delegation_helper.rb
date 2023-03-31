# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      module DelegationHelper
        def granters_for_select
          current_organization.users
        end

        def grantees_for_select
          current_organization.users
        end

        def consultations_for_select
          organization_consultations.map { |consultation| [translated_attribute(consultation.title), consultation.id] }
        end

        def ponderations_for_select(setting)
          setting.ponderations.map { |ponderation| [ponderation.title, ponderation.id] }
        end

        def organization_consultations
          Decidim::Consultations::OrganizationConsultations.new(current_organization).query
        end

        def missing_verifications_for(resources, action)
          Decidim::ResourcePermission
            .where(resource: resources)
            .where(Arel.sql("permissions->'#{action}'->'authorization_handlers'->>'delegations_verifier' IS NULL"))
            .map(&:resource)
        end

        def missing_registered_users(participants)
          participants.where.not(email: current_organization.users.select(:email))
                      .where.not("MD5(CONCAT(phone,'-',?,'-',?)) IN (?)",
                                 current_organization.id,
                                 Digest::MD5.hexdigest(Rails.application.secret_key_base),
                                 Authorization.select(:unique_id))
        end

        def participants_uniq_ids(participants)
          phones = Participant.phone_combinations(participants.pluck(:phone))
          Participant.verifier_ids(Participant.phone_combinations(phones.map { |phone| "#{phone}-#{current_organization.id}" }))
        end

        def existing_authorizations(participants)
          uniq_ids = participants_uniq_ids(participants)
          Decidim::Authorization.select(:decidim_user_id).where(unique_id: uniq_ids)
        end

        def total_missing_authorizations(participants)
          participants.count - existing_authorizations(participants).count
        end
      end
    end
  end
end
