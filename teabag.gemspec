$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "teabag/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "teabag"
  s.version     = Teabag::VERSION
  s.authors     = ["jejacks0n"]
  s.email       = ["info@modeset.com"]
  s.homepage    = "https://github.com/modeset/teabag"
  s.summary     = "Teabag: A Javascript test runner built on top of Rails"
  s.description = "Run Javascript tests using Jasmine or Mocha (with custom reporters) in the browser or headless using PhantomJS"

  s.files = Dir["{app,config,lib,vendor}/**/*"] + ["MIT.LICENSE", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "railties", "~> 3.2.5"
  s.add_dependency "phantomjs.rb", "~> 0.0.5"

  s.add_development_dependency "rspec-rails", ">= 2.11.4"
end
