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
          consultations = Consultation.where(decidim_organization_id: current_organization)
          consultations.map do |consultation|
            ConsultationPresenter.new(consultation)
          end
        end
      end
    end
  end
end
