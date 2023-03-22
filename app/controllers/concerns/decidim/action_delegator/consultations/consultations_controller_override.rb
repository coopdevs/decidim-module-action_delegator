# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module ConsultationsControllerOverride
        extend ActiveSupport::Concern

        included do
          helper ::Decidim::ActionDelegator::DelegationHelper
        end
      end
    end
  end
end
