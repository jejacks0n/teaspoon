require 'teaspoon/formatters/dot_formatter'

module Teaspoon
  module Formatters
    class CleanFormatter < DotFormatter

      def log_failed_examples
        log "\n" if failures.size > 0
      end

    end
  end
end
