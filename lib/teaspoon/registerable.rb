module Teaspoon
  module Registerable
    @@registry = {}

    def not_found_in_registry(klass)
      @@not_found_exception = klass
    end

    def register(name, constant, path)
      @@registry[normalize_name(name)] = proc {
        require path
        constant.constantize
      }
    end

    def fetch(name)
      if !(driver = @@registry[normalize_name(name)])
        raise not_found_exception.new(name: name, available: @@registry.keys)
      end
      
      driver.call
    end

    def equal?(one, two)
      normalize_name(one) == normalize_name(two)
    end

    private

    def normalize_name(name)
      name.to_s.underscore.to_sym
    end

    def not_found_exception
      @@not_found_exception || Teaspoon::NotFoundInRegistry
    end
  end
end