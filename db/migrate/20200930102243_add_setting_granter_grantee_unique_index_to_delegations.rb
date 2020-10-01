# frozen_string_literal: true

class AddSettingGranterGranteeUniqueIndexToDelegations < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_action_delegator_delegations,
              [:decidim_action_delegator_setting_id, :granter_id, :grantee_id],
              unique: true,
              name: "index_unique_setting_granter_grantee_delegation"
  end
end
