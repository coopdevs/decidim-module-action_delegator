# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module VoteFormOverride
        included do
          attribute :decidim_consultations_delegation_id, Integer
        end
      end
    end
  end
end
