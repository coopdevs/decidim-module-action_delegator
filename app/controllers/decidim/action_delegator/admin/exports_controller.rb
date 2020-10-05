# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class ExportsController < ActionDelegator::Admin::ApplicationController
        include Consultations::NeedsConsultation

        def create
          ExportConsultationResultsJob.perform_later(current_user, current_consultation)

          flash[:notice] = t("decidim.admin.exports.notice")

          redirect_back(fallback_location: decidim_admin_consultations.results_consultation_path(current_consultation))
        end
      end
    end
  end
end
