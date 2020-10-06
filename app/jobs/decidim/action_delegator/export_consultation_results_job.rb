# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ExportConsultationResultsJob < ApplicationJob
      EXPORT_NAME = "consultation_results"

      queue_as :default

      def perform(user, consultation)
        @consultation = consultation

        export_data = Decidim::Exporters.find_exporter("CSV").new(collection, serializer).export
        ExportMailer.export(user, EXPORT_NAME, export_data).deliver_now
      end

      private

      attr_reader :consultation

      def collection
        ResponsesByMembership.new.merge(PublishedQuestions.new(consultation))
      end

      def serializer
        ConsultationResultsSerializer
      end
    end
  end
end
