# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class WhodunnitVote < DelegateClass(Decidim::Consultations::Vote)
      def initialize(vote, user)
        @user = user
        super(vote)
      end

      def save
        PaperTrail.request(whodunnit: user.id) do
          super
        end
      end

      private

      attr_reader :user
    end
  end
end
