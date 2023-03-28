# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class Participant < ApplicationRecord
      self.table_name = "decidim_action_delegator_participants"

      belongs_to :setting,
                 foreign_key: "decidim_action_delegator_setting_id",
                 class_name: "Decidim::ActionDelegator::Setting"

      belongs_to :ponderation,
                 foreign_key: "decidim_action_delegator_ponderation_id",
                 class_name: "Decidim::ActionDelegator::Ponderation",
                 optional: true

      delegate :consultation, to: :setting

      validates :setting, :email, presence: true

      def user
        @user ||= if setting.email_required?
                    Decidim::User.find_by(email: email)
                  else
                    Decidim::Authorization.find_by(unique_id: uniq_id)&.user
                  end
      end

      def uniq_id
        @uniq_id ||= Digest::MD5.hexdigest(
          "#{phone}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      def user_name
        user&.name
      end

      def last_login
        user&.last_sign_in_at
      end

      def ponderation_title
        ponderation&.title
      end
    end
  end
end
