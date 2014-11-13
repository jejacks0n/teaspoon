require "active_support/core_ext/string"
require "active_support/inflector"

module Teaspoon
  module Formatters
    class Description

      attr_reader :name, :description

      def initialize(name, details)
        @name = name
        @description = details[:description]
        @default = details[:default]
      end

      def default?
        @default
      end

      def cli_help
        "  #{name}#{" (default)" if default?} - #{description}"
      end

      def class_name
        "#{name.to_s.camelize}Formatter"
      end

      def require_path
        "teaspoon/formatters/#{name}_formatter"
      end

      def <=>(other)
        name <=> other.name
      end

    end
  end
end
