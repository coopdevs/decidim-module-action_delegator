# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class QuestionWithTotals < SimpleDelegator
      def initialize(question, questions_by_id)
        super(question)
        @questions_by_id = questions_by_id
      end

      def total_delegates
        questions_by_id[id]
      end

      private

      attr_reader :questions_by_id
    end
  end
end
