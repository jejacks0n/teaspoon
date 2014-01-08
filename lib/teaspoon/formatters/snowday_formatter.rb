require 'teaspoon/formatters/dot_formatter'

module Teaspoon
  module Formatters
    class SnowdayFormatter < DotFormatter

      def spec(result)
        super(result, true)
        if result.passing?
          log "☃", GREEN
        elsif result.pending?
          log "☹", YELLOW
        else
          log "☠", RED
        end
      end

    end
  end
end
