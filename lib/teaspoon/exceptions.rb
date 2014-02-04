# todo: test
module Teaspoon
  class EnvironmentNotFound < Exception; end
  class ServerException < Exception; end
  class RunnerException < Exception; end
  class UnknownDriver < Exception; end
  class UnknownFormatter < Exception; end
  class UnknownSuite < Exception; end
  class AssetNotServable < Exception; end
  class Failure < Exception; end

  module ExceptionHandling

    def self.add_rails_handling
      return unless Teaspoon.configuration.driver == "phantomjs"

      Rails.application.config.assets.debug = false # debugging should be off to display errors in the spec_controller
      Rails.application.config.action_dispatch.show_exceptions = true # we want rails to display exceptions

      # override the render exception method in ActionDispatch to raise a javascript exception
      render_exceptions_with_javascript
    end

    private

    def self.render_exceptions_with_javascript
      ActionDispatch::DebugExceptions.class_eval do
        def render_exception(env, exception)
          message = "#{exception.class.name}: #{exception.message}"
          body = "<script>throw Error(#{message.inspect})</script>"
          [200, {'Content-Type' => "text/html;", 'Content-Length' => body.bytesize.to_s}, [body]]
        end
      end
    end
  end
end
