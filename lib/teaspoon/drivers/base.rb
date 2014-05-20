module Teaspoon
  module Drivers

    autoload :PhantomjsDriver, "teaspoon/drivers/phantomjs_driver"
    autoload :SeleniumDriver,  "teaspoon/drivers/selenium_driver"
    autoload :SlimerjsDriver,  "teaspoon/drivers/slimerjs_driver"

    class Base
    end
  end
end
