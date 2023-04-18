# frozen_string_literal: true

require "csv"

module Decidim
  module ActionDelegator
    module Admin
      # A form object used to upload CSV to batch users delegations.
      #
      class DelegationsCsvImportForm < Form
        include Decidim::HasUploadValidations

        attribute :file
        attribute :granter_email, String
        attribute :grantee_email, String

        validates :file, presence: true
        validate :validate_csv

        def validate_csv
          return if file.blank?
        end
      end
    end
  end
end
