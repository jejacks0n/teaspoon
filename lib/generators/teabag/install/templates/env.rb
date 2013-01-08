ENV["RAILS_ROOT"] = File.expand_path("../dummy", __FILE__)
require File.expand_path("../../spec/dummy/config/environment", __FILE__)

Teabag.setup do |config|
  # Driver
  #config.driver         = "phantomjs" # available: phantomjs, selenium
  #config.phantomjs_bin  = nil

  # Behaviors
  #config.server_timeout = 20 # timeout for starting the server
  #config.fail_fast      = true # stop running suites after one has failures
  #config.suppress_log   = false # suppress logs coming from console[log/error/debug]

  # Output
  #config.formatters     = "dot" # available: dot, tap_y, swayze_or_oprah
  #config.color          = true
end
