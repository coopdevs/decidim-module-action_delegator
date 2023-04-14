# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ImportParticipantsCsvJob < ApplicationJob
        queue_as :exports

        def perform(current_user, csv_file, current_setting)
          importer = Decidim::ActionDelegator::ParticipantsCsvImporter.new(csv_file, current_user, current_setting)
          import_summary = importer.import!

          details_csv_file = import_summary[:total_rows] == import_summary[:imported_rows] ? "" : import_summary[:errors_csv_path]

          Decidim::ActionDelegator::ImportParticipantsMailer
            .import(current_user, import_summary, details_csv_file).deliver_now

          import_summary
        end
      end
    end
  end
end
