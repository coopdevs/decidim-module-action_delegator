# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class UnversionedVote < SimpleDelegator
      def save
        PaperTrail.request(enabled: false) do
          super
        end
      end

      def save!
        PaperTrail.request(enabled: false) do
          super
        end
      end
    end
  end
end
