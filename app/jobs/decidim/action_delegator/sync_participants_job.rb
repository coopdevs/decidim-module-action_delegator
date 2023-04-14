# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SyncParticipantsJob < ApplicationJob
      queue_as :default

      def perform(setting)
        @setting = setting

        return unless setting&.participants

        setting.participants.each do |participant|
          next if participant.decidim_user.present?
          next if participant.user_from_metadata.blank?

          participant.decidim_user = participant.user_from_metadata
          participant.save
        end
      end

      private

      attr_reader :setting
    end
  end
end
