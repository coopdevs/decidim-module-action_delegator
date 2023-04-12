# frozen_string_literal: true

class AddDecidimActionDelegatorParticipantsUserId < ActiveRecord::Migration[6.0]
  def change
    add_reference :decidim_action_delegator_participants, :decidim_user, foreign_key: true, index: true
  end
end
