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
        "/app/views/decidim/consultations/consultations/_question.html.erb" => "2d02835e2a1538cd7f6db698e302a29b",
        # NOTE: _vote_button.html.erb is copied into _delegations_modal.html.erb, double check that view if _vote_button.html.erb changed
        "/app/views/decidim/consultations/questions/_vote_button.html.erb" => "7f3516e6d13cc4a1a9c0894b9d9fb808",
        "/app/views/decidim/consultations/questions/_vote_modal.html.erb" => "bb4b10e9278cffd8d0d4eb57f5197a89",
        "/app/views/decidim/consultations/questions/_vote_modal_confirm.html.erb" => "bac38cece8f1eaf76265fa1ad0ace064",
        "/app/views/decidim/consultations/question_multiple_votes/_form.html.erb" => "af610283ce7ee20f5ef786228a263d4a",
        # monkeypatches
        "/app/commands/decidim/consultations/vote_question.rb" => "bb0489e93d3bd142db19d9f93f556d67",
        "/app/commands/decidim/consultations/multiple_vote_question.rb" => "86ac61db829acb4e86a9b6d90bd46333",
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
