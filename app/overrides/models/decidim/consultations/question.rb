# frozen_string_literal: true

Decidim::Consultations::Question.class_eval do
  def total_delegates
    total_votes = 0

    authors = votes.select(:decidim_author_id).map(&:decidim_author_id)
    granters_ids = Decidim::ActionDelegator::Delegation.where(granter: authors).map(&:granter_id).uniq!
    granters = Decidim::User.where(id: granters_ids)

    granters.each do |granter|
      total_votes += 1 if Decidim::ActionDelegator::Delegation.granter_to?(consultation, granter)
    end

    total_votes
  end
end
