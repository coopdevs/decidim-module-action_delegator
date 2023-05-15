# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ImportCsvJob < ApplicationJob
        queue_as :exports

        def perform(importer_type, csv_file, current_user, current_setting)
          importer = if importer_type == "DelegationsCsvImporter"
                       Decidim::ActionDelegator::DelegationsCsvImporter.new(csv_file, current_user, current_setting)
                     else
                       Decidim::ActionDelegator::ParticipantsCsvImporter.new(csv_file, current_user, current_setting)
                     end

          import_summary = importer.import!

          Decidim::ActionDelegator::ImportMailer
            .import(current_user, import_summary, import_summary[:details_csv_path])
            .deliver_later

          import_summary
        end
      end
    end
  end
end
