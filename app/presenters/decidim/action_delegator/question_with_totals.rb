# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class QuestionWithTotals < SimpleDelegator
      def initialize(question, questions_by_id)
        super(question)
        @questions_by_id = questions_by_id
      end

      def total_delegates
        questions_by_id[id].total_delegates
      end

      def total_participants
        questions_by_id[id].total_participants
      end

      private

      attr_reader :questions_by_id
    end
  end
end
