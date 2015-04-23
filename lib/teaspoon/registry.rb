module Teaspoon
  module Registry
    def self.extended(host)
      host.instance_variable_set(:@registry, {})
      host.instance_variable_set(:@options, {})
    end

    def not_found_in_registry(klass)
      @not_found_exception = klass
    end

    def register(name, constant, path, options = {})
      @registry[normalize_name(name)] = proc {
        require path
        constant.constantize
      }

      @options[normalize_name(name)] = options
    end

    def fetch(name)
      if !(driver = @registry[normalize_name(name)])
        raise not_found_exception.new(name: name, available: available.keys)
      end
      
      driver.call
    end

    def equal?(one, two)
      normalize_name(one) == normalize_name(two)
    end

    def available
      @options
    end

    private

    def normalize_name(name)
      name.to_s.gsub(/[-|\s]/, '_').to_sym
    end

    def not_found_exception
      @not_found_exception || Teaspoon::NotFoundInRegistry
    end
  end
end