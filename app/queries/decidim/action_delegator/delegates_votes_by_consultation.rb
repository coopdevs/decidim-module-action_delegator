# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByConsultation < Rectify::Query
      def initialize(consultation, relation = DelegationVotes)
        @consultation = consultation
        @relation = relation
      end

      def query
        relation.new.query.merge(consultation_delegations).count
      end

      private

      attr_reader :consultation, :relation

      def consultation_delegations
        ConsultationDelegations.for(consultation)
      end
    end
  end
end
