source "https://rubygems.org"

gem "rails", "5.0.0.1"
gem "sprockets", ">= 4.0.0.beta2"

gemspec name: "teaspoon"

group :development, :test do
  gemspec name: "teaspoon-devkit"

  # frameworks
  gem "teaspoon-jasmine", path: "teaspoon-jasmine"
  gem "teaspoon-mocha", path: "teaspoon-mocha"
  gem "teaspoon-qunit", path: "teaspoon-qunit"

  # gems that teaspoon can utilize
  gem "selenium-webdriver"
  gem "capybara-webkit"

  # io services
  gem "simplecov", require: false
  gem "rubocop", require: false
end
