require "teaspoon/registry"

module Teaspoon
  module Framework
    extend Teaspoon::Registry

    not_found_in_registry Teaspoon::UnknownFramework

    def self.default
      # Frameworks are special in that the default is the first framework
      # that was registered, but can be nil, meaning the teaspoon gem is
      # in the Gemfile, instead of the framework-specific equivalent
      #   eg teaspoon-jasmine
      available.keys.first
    end
  end
end
