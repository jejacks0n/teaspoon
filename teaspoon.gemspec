$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "teaspoon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "teaspoon"
  s.version     = Teaspoon::VERSION
  s.authors     = ["jejacks0n", "jayzes", "jedschneider", "mikepack"]
  s.email       = ["info@modeset.com"]
  s.homepage    = "https://github.com/modeset/teaspoon"
  s.summary     = "Teaspoon: A Javascript test runner built on top of Rails"
  s.description = ["Run Javascript tests using Jasmine, Mocha or QUnit in the browser",
                   "or headless using PhantomJS, Selenium Webdriver, or Capybara Webkit"].join(" ")
  s.license     = "MIT"

  s.files       = Dir["{app,config,lib,vendor,bin}/**/*"] + ["MIT.LICENSE", "README.md"]
  s.executables = ["teaspoon"]


  #
  # Runtime Dependencies
  #
  s.add_dependency "selenium-webdriver"
  s.add_dependency "capybara-webkit"
  s.add_dependency "tapout"
  s.add_dependency "thin"



  #
  # Development Dependencies
  #
  s.test_files = Dir["spec/**/*"]

  # assets
  s.add_development_dependency "coffee-rails"
  s.add_development_dependency "sass-rails"
  s.add_development_dependency "haml-rails"
  s.add_development_dependency "turbolinks"
  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "uglifier"

  # rails
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "aruba"

  # io services
  s.add_development_dependency "codeclimate-test-reporter"
  s.add_development_dependency "rubocop"

end
