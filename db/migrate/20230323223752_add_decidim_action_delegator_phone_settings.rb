class AddDecidimActionDelegatorPhoneSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_action_delegator_settings, :verify_with_sms, :boolean, default: false
    add_column :decidim_action_delegator_settings, :phone_freezed, :boolean, default: false
  end
end
