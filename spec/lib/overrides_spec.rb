# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
module Decidim::ActionDelegator
  checksums = [
    {
      package: "decidim-consultations",
      files: {
        # non deface views
        "/app/views/decidim/consultations/question_votes/update_vote_button.js.erb" => "a675fe780e77e8766beef999112a8fcb",
        # deface views
        "/app/views/decidim/consultations/consultations/_question.html.erb" => "21b19519b1f249c27a536fbd1b49d619",
        # NOTE: _vote_button.html.erb is copied into _delegations_modal.html.erb, double check that view if _vote_button.html.erb changed
        "/app/views/decidim/consultations/questions/_vote_button.html.erb" => "a339b7639e8d36b0699ab3f7763872fb",
        "/app/views/decidim/consultations/questions/_vote_modal.html.erb" => "ae7c38afcc6588a00f8298ea69769da7",
        "/app/views/decidim/consultations/questions/_vote_modal_confirm.html.erb" => "a0d033ed6593f15c957393afa128ca12",
        "/app/views/decidim/consultations/question_multiple_votes/_form.html.erb" => "af610283ce7ee20f5ef786228a263d4a",
        # monkeypatches
        "/app/commands/decidim/consultations/vote_question.rb" => "8d89031039a1ba2972437d13687a72b5",
        "/app/commands/decidim/consultations/multiple_vote_question.rb" => "06d4cde2805031ecbb0c546fad567065",
        "/app/models/decidim/consultations/vote.rb" => "c06286e3f7366d3a017bf69f1c9e3eef",
        "/app/controllers/decidim/consultations/question_votes_controller.rb" => "69bf764e99dfcdae138613adbed28b84",
        "/app/forms/decidim/consultations/vote_form.rb" => "d2b69f479b61b32faf3b108da310081a",
        "/app/forms/decidim/consultations/multi_vote_form.rb" => "fc2160f0b5e85c9944d652b568c800f3"
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
