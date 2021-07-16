# frozen_string_literal: true

module Decidim
  module ActionDelegator
    class SumOfWeightsSerializer < Decidim::Exporters::Serializer
      include Decidim::TranslationsHelper

      def serialize
        {
          question: translated_attribute(resource.question_title),
          response: translated_attribute(resource.title),
          votes_count: resource.votes_count
        }
      end
    end
  end
end
