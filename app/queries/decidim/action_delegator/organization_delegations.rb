# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class OrganizationDelegations < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Delegation
          .joins(setting: :consultation)
          .merge(organization_consultations)
          .includes(:grantee, :granter)
      end

      private

      attr_reader :organization

      def organization_consultations
        Decidim::Consultations::OrganizationConsultations.new(organization).query
      end
    end
  end
end
