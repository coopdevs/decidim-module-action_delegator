# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class GranteeDelegations
      def self.for(consultation, user)
        new(consultation, user).query
      end

      def initialize(consultation, user)
        @consultation = consultation
        @user = user
      end

      def query
        ConsultationDelegations.for(consultation).where(grantee_id: user.id)
      end

      private

      attr_reader :consultation, :user
    end
  end
end
