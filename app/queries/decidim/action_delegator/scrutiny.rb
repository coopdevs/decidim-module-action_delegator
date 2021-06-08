# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class QuestionStats
      attr_reader :total_delegates, :total_participants

      def initialize(total_delegates, total_participants)
        @total_delegates = total_delegates
        @total_participants = total_participants
      end
    end

    class Scrutiny
      def initialize(consultation)
        @consultation = consultation
        @question_votes_by_id = questions_query.group_by(&:id)
      end

      def questions
        questions_cache = build_questions_cache

        question_votes_by_id.map do |_id, question_votes|
          # They are all the same question so we can pick any
          question = question_votes.first
          QuestionWithTotals.new(question, questions_cache)
        end
      end

      private

      attr_reader :consultation, :questions_cache, :question_votes_by_id

      # Returns a hash where the key is the question and the value is the numer of delegated votes
      # it got.
      def build_questions_cache
        question_votes_by_id.each_with_object({}) do |(id, questions), memo|
          total_delegations = questions.count { |question| question.granter_id.present? }
          total_participants = questions.map(&:decidim_author_id).uniq.size

          memo[id] = QuestionStats.new(total_delegations, total_participants)
          memo
        end
      end

      def questions_query
        @questions_query ||= Consultations::Question
          .select(
            '"decidim_consultations_questions".*',
            '"decidim_consultations_votes"."decidim_author_id"',
            '"decidim_action_delegator_delegations"."granter_id"'
          )
          .from(questions_joined_votes_and_delegations)
          .where(decidim_consultation_id: consultation.id)
          .merge(Consultations::Question.published)
      end

      def questions_joined_votes_and_delegations
        <<-SQL.strip_heredoc
          "decidim_consultations_questions"
          LEFT OUTER JOIN "decidim_consultations_votes"
            ON "decidim_consultations_votes"."decidim_consultation_question_id" = "decidim_consultations_questions"."id"
          LEFT JOIN "decidim_action_delegator_delegations"
            ON "decidim_consultations_votes"."decidim_author_id" = "decidim_action_delegator_delegations"."granter_id"
          LEFT JOIN "decidim_action_delegator_settings"
            ON "decidim_action_delegator_settings"."id" = "decidim_action_delegator_delegations"."decidim_action_delegator_setting_id"
          LEFT JOIN "decidim_consultations"
            ON "decidim_consultations"."id" = "decidim_action_delegator_settings"."decidim_consultation_id"
        SQL
      end
    end
  end
end
