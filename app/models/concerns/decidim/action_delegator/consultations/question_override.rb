# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module QuestionOverride
        extend ActiveSupport::Concern

        included do
          # if results can be shown to admins
          def publishable_results?
            (ActionDelegator.admin_preview_results || consultation.finished?) && sorted_results.any?
          end
        end
      end
    end
  end
end
