# frozen_string_literal: true

class AddDelegationIdToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :decidim_action_delegator_delegation_id, :integer, null: true, default: nil
  end
end
