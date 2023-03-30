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
      end
    end
  end
end
