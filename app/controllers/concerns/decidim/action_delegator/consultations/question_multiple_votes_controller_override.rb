# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module QuestionMultipleVotesControllerOverride
        extend ActiveSupport::Concern

        included do
          helper ::Decidim::ActionDelegator::DelegationHelper
          helper_method :delegation
          before_action do
            session[:delegation_id] = delegation.id if delegation
          end

          private

          def delegation
            @delegation ||= Decidim::ActionDelegator::Delegation.find_by(id: delegation_id)
          end

          def delegation_id
            @delegation_id ||= params[:decidim_consultations_delegation_id] || params[:delegation] || session[:delegation_id]
          end
        end
      end
    end
  end
end
