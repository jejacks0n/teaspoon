require "teaspoon-devkit"

# Set the path for our teaspoon_env.
# This is used within the dummy app, and allows us to tailor the teasooon
# configuration to our specific needs.
ENV["TEASPOON_ENV"] = File.expand_path("../../test/teaspoon_env.rb", __FILE__)

# Require the teaspoon-devkit spec_helper.
# This does several things, likes gives us a dummy application, capybara, aruba
# and other spec support libraries.
require Teaspoon::SPEC_HELPER
