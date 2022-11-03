# frozen_string_literal: true

require "i18n/tasks"

describe "I18n sanity" do
  let(:locales) do
    ENV["ENFORCED_LOCALES"].presence || "en"
  end

  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales.split(",")) }
  let(:non_normalized_paths) { i18n.non_normalized_paths }

  context "with missing keys" do
    let(:missing_keys) { i18n.missing_keys }

    it "does not have missing keys" do
      pending "TO DO"
      raise
      #   expect(missing_keys).to be_empty, "#{missing_keys.inspect} are missing"
    end
  end

  context "with unused keys" do
    let(:unused_keys) { i18n.unused_keys }

    it "does not have unused keys" do
      pending "TO DO"
      raise
      #   expect(unused_keys).to be_empty, "#{unused_keys.inspect} are unused"
    end
  end

  unless ENV["SKIP_NORMALIZATION"]
    it "is normalized" do
      error_message = "The following files need to be normalized:\n" \
                      "#{non_normalized_paths.map { |path| "  #{path}" }.join("\n")}\n" \
                      "Please run `bundle exec i18n-tasks normalize --locales #{locales}` to fix them"

      expect(non_normalized_paths).to be_empty, error_message
    end
  end
end
