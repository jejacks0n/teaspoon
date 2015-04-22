require "teaspoon/registerable"

module Teaspoon
  module Driver
    class Base
    end

    extend Teaspoon::Registerable

    not_found_in_registry Teaspoon::UnknownDriver
  end
end

Teaspoon::Driver.register(:phantomjs, "Teaspoon::Driver::Phantomjs", "teaspoon/driver/phantomjs")
Teaspoon::Driver.register(:selenium, "Teaspoon::Driver::Selenium", "teaspoon/driver/selenium")
Teaspoon::Driver.register(:capybara_webkit, "Teaspoon::Driver::CapybaraWebkit", "teaspoon/driver/capybara_webkit")
