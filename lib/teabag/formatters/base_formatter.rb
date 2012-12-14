module Teabag
  module Formatters
    class BaseFormatter

      attr_accessor :passes, :pendings, :failures, :errors

      def initialize
        @passes   = []
        @pendings = []
        @failures = []
        @errors   = []
      end

      def spec(result)
        if result.passing?
          @passes << result
        elsif result.pending?
          @pendings << result
        else
          @failures << result
        end
      end

      # Exceptions come from startup errors in the server
      def exception(exception = {})
        raise Teabag::RunnerException
      end

    end
  end
end
