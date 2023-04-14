# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ConsultationsController < Decidim::Consultations::Admin::ConsultationsController
        layout "decidim/admin/consultation"

        helper_method :questions, :total_delegates, :responses_by_membership, :responses_by_weight

        def results
          enforce_permission_to :read, :consultation, consultation: current_consultation
        end

        def weighted_results
          enforce_permission_to :read, :consultation, consultation: current_consultation
        end

        private

        def permission_class_chain
          Decidim.permissions_registry.chain_for(ActionDelegator::Admin::ApplicationController)
        end

        def questions
          @questions ||= Scrutiny.new(current_consultation).questions
        end

        def total_delegates
          @total_delegates ||= DelegatesVotesByConsultation.new(current_consultation).query
        end

        def responses_by_membership
          ResponsesByMembership.new(published_questions_responses).query.group_by(&:decidim_consultations_questions_id)
        end

        def responses_by_weight
          SumOfWeights.new(current_consultation).query.group_by(&:question_id)
        end

        def published_questions_responses
          VotedWithPonderations.new(PublishedResponses.new(current_consultation).query).query
        end
      end
    end
  end
end
