# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class ConsultationResultsSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      def serialize
        {
          title: translated_attribute(resource.title),
          membership_type: resource.membership_type,
          membership_weight: resource.membership_weight,
          votes_count: resource.votes_count
        }
      end
    end
  end
end
