# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
module Decidim::ActionDelegator
  checksums = [
    {
      package: "decidim-admin",
      files: {
        "/app/views/layouts/decidim/admin/users.html.erb" => "335a46bcffe8dd71477c7167eaf1cbae"
      }
    }, {
      package: "decidim-consultations",
      files: {
        # views
        "/app/views/decidim/consultations/consultations/_question.html.erb" => "364d7f8370cdbe7ae70c545fff2e21fa",
        "/app/views/decidim/consultations/consultations/show.html.erb" => "84a1569b796f724efa304b9dfc40f68a",
        "/app/views/decidim/consultations/question_votes/update_vote_button.js.erb" => "a675fe780e77e8766beef999112a8fcb",
        # NOTE: _vote_button.html.erb is copied into _delegations_modal.html.erb, double check that view if _vote_button.html.erb changed
        "/app/views/decidim/consultations/questions/_vote_button.html.erb" => "a339b7639e8d36b0699ab3f7763872fb",
        "/app/views/decidim/consultations/questions/_vote_modal.html.erb" => "ae7c38afcc6588a00f8298ea69769da7",
        "/app/views/decidim/consultations/questions/_vote_modal_confirm.html.erb" => "a0d033ed6593f15c957393afa128ca12",
        "/app/views/decidim/consultations/question_multiple_votes/_form.html.erb" => "af610283ce7ee20f5ef786228a263d4a",
        "/app/views/decidim/consultations/admin/consultations/results.html.erb" => "1a2f7afd79b20b1fcf66bdece660e8ae",
        "/app/views/layouts/decidim/admin/consultation.html.erb" => "c07fb6384e10ad23f7d7510a62ae6b24",
        "/app/views/layouts/decidim/admin/question.html.erb" => "ae4b3e289a8d7ec0243a53482ce7844b",

        # monkeypatches
        "/app/commands/decidim/consultations/vote_question.rb" => "8d89031039a1ba2972437d13687a72b5",
        "/app/commands/decidim/consultations/multiple_vote_question.rb" => "06d4cde2805031ecbb0c546fad567065",
        "/app/models/decidim/consultations/vote.rb" => "c06286e3f7366d3a017bf69f1c9e3eef",
        "/app/controllers/decidim/consultations/question_votes_controller.rb" => "69bf764e99dfcdae138613adbed28b84",
        "/app/forms/decidim/consultations/vote_form.rb" => "d2b69f479b61b32faf3b108da310081a",
        "/app/forms/decidim/consultations/multi_vote_form.rb" => "fc2160f0b5e85c9944d652b568c800f3"
      }
    }, {
      package: "decidim-verifications",
      files: {
        # views
        "/app/views/decidim/verifications/sms/authorizations/new.html.erb" => "0a526a74ef9ab7738414c1e2d0d01872",

        # monkeypatches
        "/app/controllers/decidim/verifications/sms/authorizations_controller.rb" => "4b71f48f9785058c27fcffa57579d341"
      }
    }
  ]

  describe "Overriden files", type: :view do
    checksums.each do |item|
      # rubocop:disable Rails/DynamicFindBy
      spec = ::Gem::Specification.find_by_name(item[:package])
      # rubocop:enable Rails/DynamicFindBy
      item[:files].each do |file, signature|
        it "#{spec.gem_dir}#{file} matches checksum" do
          expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
        end
      end
    end

    private

    def md5(file)
      Digest::MD5.hexdigest(File.read(file))
    end
  end
end
