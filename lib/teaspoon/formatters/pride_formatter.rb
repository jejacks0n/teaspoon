require 'teaspoon/formatters/dot_formatter'

module Teaspoon
  module Formatters
    class PrideFormatter < DotFormatter
      PI_3 = Math::PI / 3

      def initialize(*args)
        @colors = (0...(6 * 7)).map { |n|
          n *= 1.0 / 6
          r  = (3 * Math.sin(n           ) + 3).to_i
          g  = (3 * Math.sin(n + 2 * PI_3) + 3).to_i
          b  = (3 * Math.sin(n + 4 * PI_3) + 3).to_i
          36 * r + 6 * g + b + 16
        }
        @size = @colors.size
        @index = 0

        super
      end

      def spec(result)
        super(result, true)
        if result.passing?
          log_pride ".", next_color
        elsif result.pending?
          log "*", YELLOW
        else
          log "F", RED
        end
      end

      private

      def next_color
        c = @colors[@index % @size]
        @index += 1
        c
      end


      def log_pride(str, color_code)
        STDOUT.print("\e[38;5;#{color_code}m#{str}\e[0m")
      end

    end
  end
end
