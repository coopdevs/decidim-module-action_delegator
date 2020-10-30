# frozen_string_literal: true

Decidim::Consultations::Vote.class_eval do
  has_paper_trail(
    meta: {
      decidim_action_delegator_delegation_id: proc { |vote| vote.delegation&.id }
    }
  )

  # TODO: What if there is a delegation but it wasn't used? we can't know it here. The only way is
  # by passing that information from the controller.
  def delegation
    Decidim::ActionDelegator::Delegation
      .joins(setting: :consultation)
      .where(decidim_consultations: { id: question.consultation.id })
      .find_by(granter_id: decidim_author_id)
  end
end
