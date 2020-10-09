# frozen_string_literal: true

class AddSettingGranterUniqueIndexToDelegations < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_action_delegator_delegations,
              [:decidim_action_delegator_setting_id, :granter_id],
              unique: true,
              name: "index_unique_decidim_delegations_on_setting_id_granter_id"
  end
end
