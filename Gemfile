source "https://rubygems.org"

gemspec

# frameworks
gem "teaspoon-jasmine", path: "teaspoon-jasmine"
gem "teaspoon-mocha", path: "teaspoon-mocha"
gem "teaspoon-qunit", path: "teaspoon-qunit"

# gems that teaspoon can utilize
gem "selenium-webdriver"
gem "capybara-webkit"
gem "tapout"
gem "thin"

# used by the dummy application
gem "rails", ">= 4.2.0"
gem "coffee-rails"
gem "sass-rails"
gem "haml-rails"
gem "turbolinks"
gem "jquery-rails"

# used by test rails apps
gem "sqlite3"
gem "uglifier"

group :development, :test do
  gem "rspec-rails"
  gem "capybara"
  gem "aruba"
end

# io services
gem "codeclimate-test-reporter", group: :test, require: nil
gem "rubocop", require: false
