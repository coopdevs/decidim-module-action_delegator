module Decidim
  module ActionDelegator
    module Admin
      module Results
        class SumOfWeightsController < Decidim::Consultations::Admin::ConsultationsController
          helper_method :responses_for

          def index
            params[:slug] = params[:consultation_slug]

            enforce_permission_to :read, :consultation, consultation: current_consultation
            @questions = questions

            render layout: "decidim/admin/consultation"
          end

          private

          def questions
            current_consultation.questions.published.includes(:responses)
          end

          def responses_for(question)
            responses.fetch(question.id, [])
          end

          def responses
            @responses ||= responses_by_membership.group_by(&:decidim_consultations_questions_id)
          end

          def responses_by_membership
            ResponsesByMembership.new(published_questions_responses).query
          end

          def published_questions_responses
            PublishedResponses.new(current_consultation).query
          end
        end
      end
    end
  end
end
