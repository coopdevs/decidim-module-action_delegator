# frozen_string_literal: true

Decidim::Consultations::Question.class_eval do
  def total_delegates
    Decidim::User
      .joins("INNER JOIN decidim_action_delegator_delegations
                ON decidim_users.id = decidim_action_delegator_delegations.granter_id
              INNER JOIN decidim_consultations_votes
                ON decidim_consultations_votes.decidim_author_id = decidim_action_delegator_delegations.granter_id")
      .where(decidim_action_delegator_delegations: { granter_id: votes.pluck(:decidim_author_id) }).distinct.count
  end
end
