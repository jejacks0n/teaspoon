module Teaspoon
  module Drivers
    autoload :PhantomjsDriver, "teaspoon/drivers/phantomjs_driver"
    autoload :SeleniumDriver, "teaspoon/drivers/selenium_driver"
    autoload :CapybaraWebkitDriver, "teaspoon/drivers/capybara_webkit_driver"

    class Base
    end
  end
end
