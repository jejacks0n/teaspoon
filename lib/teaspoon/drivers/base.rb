module Teaspoon
  module Drivers
    @@drivers = {}

    class Base
      def self.register_driver(name)
        Teaspoon::Drivers.class_variable_get(:@@drivers)[name] = self
      end
    end

    def self.fetch(name)
      @@drivers[name.to_sym] or raise Teaspoon::UnknownDriver.new(name: name, available: @@drivers.keys)
    end
  end
end

require "teaspoon/drivers/phantomjs_driver"
require "teaspoon/drivers/selenium_driver"
require "teaspoon/drivers/capybara_webkit_driver"
