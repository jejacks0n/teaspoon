# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "teaspoon/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "teaspoon"
  s.version     = Teaspoon::VERSION
  s.authors     = ["jejacks0n", "mikepack", "jayzes", "jedschneider"]
  s.email       = ["jejacks0n@gmail.com"]
  s.homepage    = "https://github.com/jejacks0n/teaspoon"
  s.summary     = "Teaspoon: A Javascript test runner built on top of Rails"
  s.description = "Run your Javascript tests using Jasmine, Mocha or QUnit using a variety of platforms."
  s.license     = "MIT"
  s.files       = Dir["{app,lib,bin}/**/*"] + ["MIT.LICENSE", "README.md", "CHANGELOG.md"]
  s.executables = ["teaspoon"]

  s.required_ruby_version = ">= 2.7"
  s.add_runtime_dependency "railties", ">= 5.0"
  s.add_dependency "erb"
  s.add_development_dependency "simplecov", "< 0.18"
  if RUBY_VERSION > "3"
    s.add_development_dependency "webrick"
  end
end
