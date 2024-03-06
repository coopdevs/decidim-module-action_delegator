# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module QuestionOverride
        extend ActiveSupport::Concern

        included do
          # if results can be shown to admins
          def publishable_results?
            (ActionDelegator.admin_preview_results || consultation.finished?) && sorted_results.any?
          end

          def weighted_responses
            @weighted_responses ||= Decidim::ActionDelegator::SumOfWeights.new(consultation).query.group_by(&:question_id)
          end

          def total_weighted_votes
            @total_weighted_votes ||= weighted_responses[id].sum(&:votes_count)
          end

          def most_weighted_voted_response
            weighted_responses[id].max_by(&:votes_count)
          end

          def responses_sorted_by_weighted_votes
            @responses_sorted_by_weighted_votes ||= weighted_responses.transform_values do |responses|
              responses.sort_by { |response| -response.votes_count }
            end
          end
        end
      end
    end
  end
end
