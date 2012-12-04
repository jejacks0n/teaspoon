# This file is used by Rack-based servers to start the application.

require 'rails/commands/server'

module Rails
  class Server
    alias :default_options_alias :default_options
    def default_options
      default_options_alias.merge!(:Port => 3333)
    end
  end
end

require ::File.expand_path('../config/environment',  __FILE__)
run Dummy::Application
