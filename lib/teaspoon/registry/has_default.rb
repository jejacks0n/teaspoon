module Teaspoon
  module Registry
    module HasDefault
      def default
        available.find do |formatter,options|
          options[:default]
        end.first
      end
    end
  end
end