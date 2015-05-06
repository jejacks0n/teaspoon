$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "teaspoon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "teaspoon-devkit"
  s.version     = Teaspoon::VERSION
  s.authors     = ["jejacks0n", "mikepack"]
  s.email       = ["info@modeset.com"]
  s.homepage    = "https://github.com/modeset/teaspoon"
  s.summary     = "Teaspoon: A Javascript test runner built on top of Rails"
  s.description = ["Devkit for Teaspoon -- test dependencies, rails app, and more for developing teaspoon ties"]
  s.license     = "MIT"

  s.files       = Dir["{spec}/**/*"] + ["Rakefile", "MIT.LICENSE", "README.md"]

  # dummy app dependencies
  s.add_dependency "rails", [">= 3.2.5"]
  s.add_dependency "coffee-rails"
  s.add_dependency "sass-rails"
  s.add_dependency "haml-rails"
  s.add_dependency "jquery-rails"

  # test dependencies
  s.add_dependency "rspec-rails"
  s.add_dependency "capybara"
  s.add_dependency "aruba"
  s.add_dependency "appraisal"

  # for local bundle installs
  s.add_dependency "jbuilder"
  s.add_dependency "sdoc"
end
