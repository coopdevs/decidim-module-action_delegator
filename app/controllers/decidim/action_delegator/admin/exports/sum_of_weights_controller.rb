# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      module Exports
        class SumOfWeightsController < Admin::Consultations::ExportsController
          def type
            "sum_of_weights"
          end
        end
      end
    end
  end
end
