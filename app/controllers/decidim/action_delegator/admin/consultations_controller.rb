# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ConsultationsController < Decidim::Consultations::Admin::ConsultationsController
        helper_method :responses_for

        def results
          enforce_permission_to :read, :consultation, consultation: current_consultation

          @questions = questions

          render layout: "decidim/admin/consultation"
        end

        private

        def permission_class_chain
          Decidim.permissions_registry.chain_for(ActionDelegator::Admin::ApplicationController)
        end

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
