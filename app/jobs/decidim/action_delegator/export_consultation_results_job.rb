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
        consultation.questions.published.includes(:responses).flat_map do |question|
          Decidim::ActionDelegator::ResponsesByMembership.new(question).query
        end
      end

      def serializer
        ConsultationResultsSerializer
      end
    end
  end
end
