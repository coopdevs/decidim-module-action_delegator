# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ExportConsultationResultsJob < ApplicationJob
      queue_as :default

      def perform(user, consultation)
        @consultation = consultation

        export_data = Decidim::Exporters.find_exporter("CSV").new(collection, serializer).export
        ExportMailer.export(user, I18n.t("decidim.admin.consultations.results.export_filename"), export_data).deliver_now
      end

      private

      attr_reader :consultation

      def collection
        ResponsesByMembership.new.query.merge(published_questions_responses)
      end

      # Returns the published questions' responses of the given consultation as an ActiveRecord
      # Relation. Note this enables us to the chain it with other AR Relation objects.
      def published_questions_responses
        PublishedResponses.new(consultation).query
      end

      def serializer
        ConsultationResultsSerializer
      end
    end
  end
end
