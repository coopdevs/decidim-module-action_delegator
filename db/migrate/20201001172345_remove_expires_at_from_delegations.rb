# frozen_string_literal: true

class RemoveExpiresAtFromDelegations < ActiveRecord::Migration[5.2]
  def change
    remove_column :decidim_action_delegator_settings, :expires_at
  end
end
