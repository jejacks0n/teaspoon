module Teaspoon
  DEV_PATH = File.expand_path("../../", __FILE__)
  SPEC_HELPER = File.join(DEV_PATH, "spec", "spec_helper")
  FIXTURE_PATH = File.join(DEV_PATH, "spec", "javascripts", "fixtures")
  RAKEFILE = File.join(DEV_PATH, "Rakefile")
  def self.require_dummy!
    unless defined?(Rails)
      ENV["RAILS_ROOT"] = File.join(DEV_PATH, "spec", "dummy")
      require File.join(ENV["RAILS_ROOT"], "config", "environment")
    end
  end
end
