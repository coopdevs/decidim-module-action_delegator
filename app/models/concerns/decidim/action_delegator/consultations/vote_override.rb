# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Consultations
      module VoteOverride
        extend ActiveSupport::Concern

        included do
          has_paper_trail
        end
      end
    end
  end
end
