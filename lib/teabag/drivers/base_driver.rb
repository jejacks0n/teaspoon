module Teabag
  module Drivers

    autoload :PhantomjsDriver, 'teabag/drivers/phantomjs_driver'
    autoload :SeleniumDriver,  'teabag/drivers/selenium_driver'

    class BaseDriver
    end
  end
end
