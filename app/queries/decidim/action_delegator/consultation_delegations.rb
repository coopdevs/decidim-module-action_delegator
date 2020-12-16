# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ConsultationDelegations < Rectify::Query
      def self.for(consultation, user)
        new(consultation, user).query
      end

      def self.granter_for(consultation, user)
        new(user, consultation).query_granter
      end

      def initialize(consultation, user)
        @consultation = consultation
        @user = user
      end

      def query
        Delegation
          .joins(setting: :consultation)
          .where(decidim_consultations: { id: consultation.id })
          .where(grantee_id: user.id)
      end

      def query_granter
        Delegation
          .joins(setting: :consultation)
          .where(decidim_consultations: { id: consultation.id })
          .where(granter_id: user.id)
      end

      private

      attr_reader :consultation, :user
    end
  end
end
