# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class PublishedResponses < Rectify::Query
      def initialize(consultation)
        @consultation = consultation
      end

      # The Question's default_scope, `order(order: :asc)`, messes up the ordering in our queries so
      # we have to explicitly remove the ORDER BY close using `#reorder`.
      def query
        Consultations::Response
          .joins(question: :consultation)
          .merge(Consultation.finished)
          .where(decidim_consultations_questions: { decidim_consultation_id: consultation.id })
          .where.not(decidim_consultations_questions: { published_at: nil })
      end

      private

      attr_reader :consultation
    end
  end
end
