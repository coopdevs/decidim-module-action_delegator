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

      validates :setting, presence: true

      def user
        @user ||= if setting.email_required?
                    Decidim::User.find_by(email: email)
                  else
                    Decidim::Authorization.find_by(unique_id: uniq_ids)&.user
                  end
      end

      def uniq_ids
        @uniq_ids ||= phone_prefixes.map do |prefix|
          [
            Digest::MD5.hexdigest("#{prefix}#{phone}-#{Rails.application.secrets.secret_key_base}"),
            Digest::MD5.hexdigest("#{phone.delete_prefix(prefix)}-#{Rails.application.secrets.secret_key_base}")
          ]
        end.flatten
      end

      def phone_prefixes
        @phone_prefixes = [""]
        @phone_prefixes += ActionDelegator.phone_prefixes if ActionDelegator.phone_prefixes.respond_to?(:map)
        @phone_prefixes
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
