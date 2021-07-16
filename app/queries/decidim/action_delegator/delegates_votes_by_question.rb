# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByQuestion < Rectify::Query
      def initialize(question)
        @question = question
      end

      def query
        DelegationVotes.new.query
          .merge(question.votes)
          .merge(consultation_delegations)
          .distinct.count(:granter_id)
      end

      private

      attr_reader :question

      def consultation_delegations
        ConsultationDelegations.for(question.consultation)
      end
    end
  end
end
