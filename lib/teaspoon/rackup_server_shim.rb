require 'rack'
require 'rackup'

module Teaspoon
	if Gem::Version.new(Rack.release) > '3.0'
		RackupServerShim = ::Rackup::Server
	else
		RackupServerShim = ::Rack::Server
  end
end
