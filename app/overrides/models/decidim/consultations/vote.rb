# frozen_string_literal: true

Decidim::Consultations::Vote.class_eval do
  has_paper_trail
end
