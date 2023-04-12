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
      delegate :organization, to: :setting

      validates :setting, presence: true

      def user
        user_from_metadata
      end

      def user_from_metadata
        @user_from_metadata ||= if setting.email_required?
                    Decidim::User.find_by(email: email)
                  else
                    Decidim::Authorization.find_by(unique_id: uniq_ids)&.user
                  end
      end

      def uniq_ids
        @uniq_ids ||= Participant.verifier_ids(Participant.phone_combinations(["#{phone}-#{organization.id}"]))
      end

      def self.verifier_ids(seeds)
        seeds.map { |seed| Digest::MD5.hexdigest("#{seed}-#{Digest::MD5.hexdigest(Rails.application.secrets.secret_key_base)}") }
      end

      def self.phone_combinations(phones)
        phones.map do |phone|
          phone_prefixes.map do |prefix|
            [
              "#{prefix}#{phone}",
              phone.delete_prefix(prefix)
            ]
          end
        end.flatten.uniq
      end

      def self.phone_prefixes
        prefixes = [""]
        prefixes += ActionDelegator.phone_prefixes if ActionDelegator.phone_prefixes.respond_to?(:map)
        prefixes
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
