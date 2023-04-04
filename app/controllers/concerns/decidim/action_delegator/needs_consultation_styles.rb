# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module NeedsConsultationStyles
      extend ActiveSupport::Concern

      included do
        helper_method :snippets
      end

      def snippets
        @snippets ||= Decidim::Snippets.new

        unless @snippets.any?(:action_delegator_consultation_questions)
          @snippets.add(:action_delegator_consultation_questions, ActionController::Base.helpers.stylesheet_pack_tag("decidim_action_delegator_questions"))
          @snippets.add(:head, @snippets.for(:action_delegator_consultation_questions))
        end

        @snippets
      end
    end
  end
end
