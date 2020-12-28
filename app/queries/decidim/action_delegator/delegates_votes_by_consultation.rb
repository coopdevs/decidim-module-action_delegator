# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByConsultation < Rectify::Query
      def initialize(consultation, relation = nil)
        @relation = relation.presence || Decidim::ActionDelegator::DelegatesVotesByQuestion
        @consultation = consultation
      end

      def total_delegates
        total_count = 0

        @consultation.questions.each { |q| total_count += @relation.new(q).query }

        total_count
      end
    end
  end
end
