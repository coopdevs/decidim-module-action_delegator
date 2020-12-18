# frozen_string_literal: true

Decidim::Consultation.class_eval do
  # The authors from the question's votes must be granters and
  # belong to the consultation. Then make a count of votes by author and those
  # that belong to the granters are the total delegated votes.
  def total_delegates
    total_votes = 0

    votes_authors_ids = questions.published.map(&:votes).flatten.map(&:decidim_author_id)
    votes_from_authors = votes_authors_ids.group_by(&:itself).transform_values(&:count) # { id -> num of votes }
    granters = Decidim::User.where(id: Decidim::ActionDelegator::Delegation.where(granter: votes_authors_ids).map(&:granter_id).uniq)
    granters.select { |g| Decidim::ActionDelegator::Delegation.granter_to?(self, g) }

    granters.each do |user|
      total_votes = votes_from_authors.has_key?(user.id) ? votes_from_authors[user.id] : 0
    end

    total_votes
  end
end
