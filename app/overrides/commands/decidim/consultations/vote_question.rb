# frozen_string_literal: true

Decidim::Consultations::VoteQuestion.class_eval do
  private

  def build_vote
    if delegation
      form.context.delegation = delegation
      Decidim::ActionDelegator::VoteDelegation.new(form).call
    else
      vote = form.context.current_question.votes.build(
        author: form.context.current_user,
        response: form.response
      )
      Decidim::ActionDelegator::UnversionedVote.new(vote)
    end
  end

  def delegation
    @delegation ||= Decidim::ActionDelegator::ConsultationDelegations.for(
      form.context.current_question.consultation,
      form.context.current_user
    ).find_by(id: form.decidim_consultations_delegation_id)
  end
end
