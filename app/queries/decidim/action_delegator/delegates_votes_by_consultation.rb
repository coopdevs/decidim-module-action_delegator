# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByConsultation < Rectify::Query
      def initialize(consultation, relation = nil)
        @relation = relation.presence || Decidim::ActionDelegator::DelegatesVotes
        @consultation = consultation
      end

      def query
        authors_ids_votes = Decidim::Consultations::Vote
                            .joins("INNER JOIN decidim_consultations_questions
                                        ON decidim_consultations_votes.decidim_consultation_question_id = decidim_consultations_questions.id
                                      INNER JOIN decidim_consultations
                                        ON decidim_consultations.id = decidim_consultations_questions.decidim_consultation_id")
                            .where(decidim_consultations: { id: consultation.id })
                            .pluck(:decidim_author_id)
        relation.new(authors_ids_votes).query.count
      end

      private

      attr_reader :consultation, :relation
    end
  end
end
