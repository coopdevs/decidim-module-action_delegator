class AddDecidimActionDelegatorVerificationMethod < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_action_delegator_settings, :authorization_method, :integer, default: 0, null: false
  end
end
