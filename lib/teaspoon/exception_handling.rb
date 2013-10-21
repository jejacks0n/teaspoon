# todo: exception handling like this should probably be configurable, because it may cause issues in some setups.
require 'action_dispatch/middleware/debug_exceptions'

if Teaspoon.configuration.driver == "phantomjs"
  # debugging should be off to display errors in the spec_controller
  Rails.application.config.assets.debug = false

  # we want rails to display exceptions
  Rails.application.config.action_dispatch.show_exceptions = true

  class ActionDispatch::DebugExceptions
    def render_exception(env, exception)
      message = "#{exception.class.name}: #{exception.message}"
      body = "<script>throw Error(#{message.inspect})</script>"
      [200, {'Content-Type' => "text/html;", 'Content-Length' => body.bytesize.to_s}, [body]]
    end
  end
end
