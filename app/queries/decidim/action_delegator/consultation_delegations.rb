# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ConsultationDelegations < Rectify::Query
      def self.for(consultation)
        new(consultation).query
      end

      def initialize(consultation)
        @consultation = consultation
      end

      def query
        Delegation
          .joins(setting: :consultation)
          .where(decidim_consultations: { id: consultation.id })
      end

      private

      attr_reader :consultation
    end
  end
end
