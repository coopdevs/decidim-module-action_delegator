# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/consultations/admin/consultations/results",
                     name: "add_delegate_votes_by_results_view",
                     insert_after: "erb[loud]:contains('count: question.total_votes')",
                     text: " / <%= t 'decidim.admin.consultations.results.total_delegates', count: question.total_delegates %>")
