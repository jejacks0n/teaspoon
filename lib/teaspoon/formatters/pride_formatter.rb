module Teaspoon
  module Formatters
    class PrideFormatter < DotFormatter

      PI_3 = Math::PI / 3

      def initialize(*args)
        @color_index = 0
        super
      end

      protected

      def log_spec(result)
        return log_pride if result.passing?
        super
      end

      private

      def log_pride
        return log_str(".") unless Teaspoon.configuration.color
        log_str("\e[38;5;#{next_color}m.\e[0m")
      end

      def colors
        @colors ||= (0...42).map do |i|
          i *= 1.0 / 6
          36 * calc_color(i) + 6 * calc_color(i + 2 * PI_3) + calc_color(i + 4 * PI_3) + 16
        end
      end

      def calc_color(val)
        (3 * Math.sin(val) + 3).to_i
      end

      def next_color
        c = colors[@color_index % colors.size]
        @color_index += 1
        c
      end
    end
  end
end
