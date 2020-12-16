# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/consultations/admin/consultations/results",
                     name: "add_delegate_votes_to_total_results_view",
                     insert_after: "erb[loud]:contains('count: current_consultation.total_votes')",
                     text: " / <%= t 'decidim.admin.consultations.results.total_delegates', count: current_consultation.total_delegates %>")
