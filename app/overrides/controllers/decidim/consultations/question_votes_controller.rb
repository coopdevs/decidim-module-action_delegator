# frozen_string_literal: true

Decidim::Consultations::QuestionVotesController.class_eval do
  def destroy
    enforce_permission_to_unvote

    user = delegation.blank? ? current_user : delegation.granter

    PaperTrail.request(enabled: delegation.present?, whodunnit: current_user.id) do
      Decidim::Consultations::UnvoteQuestion.call(current_question, user) do
        on(:ok) do
          current_question.reload
          render :update_vote_button
        end
      end
    end
  end

  private

  def info_for_paper_trail
    if delegation.present?
      { decidim_action_delegator_delegation_id: delegation.id }
    else
      {}
    end
  end

  def delegation
    @delegation ||= Decidim::ActionDelegator::Delegation.find_by(id: params[:decidim_consultations_delegation_id])
  end

  def enforce_permission_to_unvote
    if delegation.blank?
      enforce_permission_to :unvote, :question, question: current_question
    else
      raise Decidim::ActionForbidden unless allowed_to?(
        :unvote_delegation,
        :question,
        { question: current_question, delegation: delegation },
        [Decidim::ActionDelegator::Permissions, Decidim::Admin::Permissions, Decidim::Permissions]
      )
    end
  end
end
