# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      module Results
        class SumOfWeightsController < Decidim::Consultations::Admin::ConsultationsController
          def index
            params[:slug] = params[:consultation_slug]

            enforce_permission_to :read, :consultation, consultation: current_consultation

            @questions = questions
            @responses = responses.group_by(&:decidim_consultations_questions_id)

            render layout: "decidim/admin/consultation"
          end

          private

          def permission_class_chain
            Decidim.permissions_registry.chain_for(ActionDelegator::Admin::ApplicationController)
          end

          def questions
            current_consultation.questions.published.includes(:responses)
          end

          def responses
            SumOfMembershipWeight.new(published_questions_responses).query
          end

          def published_questions_responses
            VotedResponses.new(PublishedResponses.new(current_consultation).query).query
          end
        end
      end
    end
  end
end
