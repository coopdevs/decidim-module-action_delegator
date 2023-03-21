# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module ActionDelegator
    module Consultations
      module VoteQuestionOverride
        extend ActiveSupport::Concern

        included do
          private

          def build_vote
            if delegation
              form.context.delegation = delegation
              Decidim::ActionDelegator::VoteDelegation.new(form.response, form.context).call
            else
              vote = form.context.current_question.votes.build(
                author: form.context.current_user,
                response: form.response
              )
              Decidim::ActionDelegator::UnversionedVote.new(vote)
            end
          end

          def delegation
            @delegation ||= Decidim::ActionDelegator::GranteeDelegations.for(
              form.context.current_question.consultation,
              form.context.current_user
            ).find_by(id: delegation_id)
          end

          def delegation
            @delegation ||= Decidim::ActionDelegator::Delegation.find_by(id: delegation_id)
          end

          def delegation_id
            @delegation_id ||= session[:delegation_id] || form.decidim_consultations_delegation_id
          end
        end
      end
    end
  end
end
