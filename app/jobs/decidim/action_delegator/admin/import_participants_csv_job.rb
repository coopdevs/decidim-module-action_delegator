# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ImportParticipantsCsvJob < ApplicationJob
        queue_as :exports

        def perform(current_user, csv_file, current_setting)
          importer = Decidim::ActionDelegator::ParticipantsCsvImporter.new(csv_file, current_user, current_setting)
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
