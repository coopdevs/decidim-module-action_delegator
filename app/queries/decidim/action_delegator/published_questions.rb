# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class PublishedQuestions < Rectify::Query
      def initialize(consultation)
        @consultation = consultation
      end

      def query
        # The Question's default_scope, `order(order: :asc)`, messes up the ordering in our queries.
        consultation.questions.published.includes(:responses).unscoped
      end

      private

      attr_reader :consultation
    end
  end
end
