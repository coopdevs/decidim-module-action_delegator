# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByQuestion < Rectify::Query
      def initialize(question, relation = Decidim::ActionDelegator::DelegatesVotes)
        @question = question
        @relation = relation
      end

      def query
        relation.new.query.merge(question.votes).distinct.count
      end

      private

      attr_reader :question, :relation
    end
  end
end
