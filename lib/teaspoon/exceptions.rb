module Teaspoon
  class Error < Exception; end
  class EnvironmentNotFound < Teaspoon::Error; end
  class MissingDependency < Teaspoon::Error; end
  class ServerException < Teaspoon::Error; end
  class RunnerException < Teaspoon::Error; end
  class ExporterException < Teaspoon::Error; end
  class UnknownFramework < Teaspoon::Error; end
  class UnknownDriver < Teaspoon::Error; end
  class UnknownDriverOptions < Teaspoon::Error; end
  class UnknownFormatter < Teaspoon::Error; end
  class UnknownSuite < Teaspoon::Error; end
  class AssetNotServable < Teaspoon::Error; end
  class Failure < Teaspoon::Error; end
  class DependencyFailure < Teaspoon::Error; end
  class ThresholdNotMet < Teaspoon::Error; end
  class FileNotWritable < Teaspoon::Error; end

  module ExceptionHandling

    def self.add_rails_handling
      return unless Teaspoon.configuration.driver == "phantomjs"

      #Rails.application.config.assets.debug = false # debugging should be off to display errors in the suite_controller
      Rails.application.config.action_dispatch.show_exceptions = true # we want rails to display exceptions

      # override the render exception method in ActionDispatch to raise a javascript exception
      render_exceptions_with_javascript
    end

    private

    def self.render_exceptions_with_javascript
      ActionDispatch::DebugExceptions.class_eval do
        def render_exception(env, exception)
          message = "#{exception.class.name}: #{exception.message}"
          body = "<script>throw Error(#{[message, exception.backtrace].join("\n").inspect})</script>"
          [200, {'Content-Type' => "text/html;", 'Content-Length' => body.bytesize.to_s}, [body]]
        end
      end
    end
  end
end
