# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/action_delegator/version"

MIN_DECIDIM_VERSION = Decidim::ActionDelegator::MIN_DECIDIM_VERSION
MAX_DECIDIM_VERSION = Decidim::ActionDelegator::MAX_DECIDIM_VERSION

Gem::Specification.new do |s|
  s.version = Decidim::ActionDelegator::VERSION
  s.authors = ["Pau Pérez Fabregat", "Ivan Vergés"]
  s.email = ["saulopefa@gmail.com", "ivan@platoniq.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/coopdevs/decidim-module-action_delegator"
  s.required_ruby_version = ">= 2.7.1"

  s.name = "decidim-action_delegator"
  s.summary = "A Decidim ActionDelegator module"
  s.description = "A tool for Decidim that provides extended functionalities for cooperatives and allows delegated voting."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", [MIN_DECIDIM_VERSION, MAX_DECIDIM_VERSION]
  s.add_dependency "decidim-consultations", [MIN_DECIDIM_VERSION, MAX_DECIDIM_VERSION]
  s.add_dependency "decidim-core", [MIN_DECIDIM_VERSION, MAX_DECIDIM_VERSION]
  s.add_dependency "savon"
  s.add_dependency "twilio-ruby"

  s.add_development_dependency "decidim-dev", [MIN_DECIDIM_VERSION, MAX_DECIDIM_VERSION]
end
