#!/usr/bin/env rake
require 'fileutils'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

# Dummy App
# -----------------------------------------------------------------------------
APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'
Bundler::GemHelper.install_tasks

# RSpec
# -----------------------------------------------------------------------------
load 'rspec/rails/tasks/rspec.rake'

# Teabag
# -----------------------------------------------------------------------------
load File.expand_path('../lib/tasks/teabag.rake', __FILE__)

# Default
# -----------------------------------------------------------------------------
Rake::Task['default'].prerequisites.clear
Rake::Task['default'].clear

task :default => [:spec, :teabag]
