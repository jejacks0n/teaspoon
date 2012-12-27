source :rubygems

gemspec

# gems that teabag can utilize
gem "selenium-webdriver"
gem "tapout"

# used by the dummy application
gem "rails", ">= 3.2.9"
gem "coffee-rails"
gem "sass-rails"
gem "jquery-rails"
gem "haml-rails"

# required for travis-ci and linux environments
if RUBY_PLATFORM =~ /linux/
  gem 'phantomjs-linux'
end
