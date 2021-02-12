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
        "/app/views/layouts/decidim/admin/users.html.erb" => "8d2622bcea84aa844896123499619bc3"
      }
    }, {
      package: "decidim-consultations",
      files: {
        # views
        "/app/views/decidim/consultations/consultations/_question.html.erb" => "364d7f8370cdbe7ae70c545fff2e21fa",
        "/app/views/decidim/consultations/consultations/show.html.erb" => "84a1569b796f724efa304b9dfc40f68a",
        "/app/views/decidim/consultations/question_votes/update_vote_button.js.erb" => "a675fe780e77e8766beef999112a8fcb",
        # NOTE: _vote_button.html.erb is copied into _delegations_modal.html.erb, double check that view if _vote_button.html.erb changed
        "/app/views/decidim/consultations/questions/_vote_button.html.erb" => "ac4b6314c4f11216764fa8977d4f829f",
        "/app/views/decidim/consultations/questions/_vote_modal.html.erb" => "ae7c38afcc6588a00f8298ea69769da7",
        "/app/views/decidim/consultations/questions/_vote_modal_confirm.html.erb" => "a0d033ed6593f15c957393afa128ca12",
        "/app/views/decidim/consultations/admin/consultations/results.html.erb" => "1a2f7afd79b20b1fcf66bdece660e8ae",
        "/app/views/layouts/decidim/admin/consultation.html.erb" => "7f70f790cf474389f327528136d366a3",
        "/app/views/layouts/decidim/admin/question.html.erb" => "e844ffab48c19671583e9cb4eaf4e1dc",

        # monkeypatches
        "/app/commands/decidim/consultations/vote_question.rb" => "8d89031039a1ba2972437d13687a72b5",
        "/app/models/decidim/consultations/vote.rb" => "c06286e3f7366d3a017bf69f1c9e3eef",
        "/app/controllers/decidim/consultations/question_votes_controller.rb" => "69bf764e99dfcdae138613adbed28b84",
        "/app/forms/decidim/consultations/vote_form.rb" => "d2b69f479b61b32faf3b108da310081a"
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
