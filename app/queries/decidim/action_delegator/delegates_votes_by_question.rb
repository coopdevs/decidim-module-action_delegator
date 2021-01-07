# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class DelegatesVotesByQuestion < Rectify::Query
      def initialize(question, relation = nil)
        @authors_ids_votes = question.votes.pluck(:decidim_author_id)
        @relation = relation.presence || Decidim::ActionDelegator::DelegatesVotes
      end

      def query
        relation.new(authors_ids_votes).query.distinct.count
      end

      private

      attr_reader :authors_ids_votes, :relation
    end
  end
end
