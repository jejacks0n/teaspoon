source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec name: "teaspoon"
gemspec name: "teaspoon-devkit"

gem "rails"
gem "puma"

# frameworks
gem "teaspoon-jasmine", path: "teaspoon-jasmine"
gem "teaspoon-mocha", path: "teaspoon-mocha"
gem "teaspoon-qunit", path: "teaspoon-qunit"

# gems that teaspoon can utilize
gem "selenium-webdriver"

# test dependencies
gem "rspec-rails"
gem "simplecov"

# services
gem "rubocop", require: false
gem "rubocop-rails_config"
