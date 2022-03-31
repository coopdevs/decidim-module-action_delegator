# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ExportConsultationResultsJob < ApplicationJob
      queue_as :default

      def perform(user, consultation, results_type)
        @consultation = consultation
        @results_type = results_type.to_sym

        export_data = Decidim::Exporters
                      .find_exporter("CSV")
                      .new(collection, serializer)
                      .export

        Decidim::ExportMailer.export(user, filename, export_data).deliver_now
      end

      private

      attr_reader :consultation, :results_type

      def collection
        query_class.new(consultation).query
      end

      def query_class
        case results_type
        when :sum_of_weights
          SumOfWeights
        when :type_and_weight
          TypeAndWeight
        end
      end

      def serializer
        case results_type
        when :sum_of_weights
          SumOfWeightsSerializer
        when :type_and_weight
          ConsultationResultsSerializer
        end
      end

      def filename
        I18n.t("decidim.admin.consultations.results.export_filename")
      end
    end
  end
end
