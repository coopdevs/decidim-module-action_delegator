# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module Decidim
  module ActionDelegator
    module Consultations
      module MultipleVoteQuestionOverride
        extend ActiveSupport::Concern
        include VoteQuestionOverride

        included do
          private

          def create_vote!(vote_form)
            vote = if delegation
                     form.context.delegation = delegation
                     Decidim::ActionDelegator::VoteDelegation.new(vote_form.response, form.context).call
                   else
                     normal_vote = vote_form.context.current_question.votes.build(
                       author: @current_user,
                       response: vote_form.response
                     )
                     Decidim::ActionDelegator::UnversionedVote.new(normal_vote)
                   end
            vote.save!
          end
        end
      end
    end
  end
end
