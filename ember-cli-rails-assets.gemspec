$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ember_cli/assets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ember-cli-rails-assets"
  s.version     = EmberCli::Assets::VERSION
  s.authors     = ["Sean Doyle", "Ryunosuke Sato"]
  s.email       = ["sean.p.doyle24@gmail.com", "tricknotes.rs@gmail.com"]
  s.homepage    = "https://github.com/tricknotes/ember-cli-rails-assets"
  s.summary     = "Include EmberCLI-generated JavaScript and CSS stylesheet tags in your Rails layouts"
  s.description = "Include EmberCLI-generated JavaScript and CSS stylesheet tags in your Rails layouts"
  s.license     = "MIT"

  s.files = Dir["{app,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'nokogiri'
end
