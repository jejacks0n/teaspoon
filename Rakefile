#!/usr/bin/env rake
require "fileutils"

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

# Dummy App
# -----------------------------------------------------------------------------
APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"
Bundler::GemHelper.install_tasks

# RSpec
# -----------------------------------------------------------------------------
load "rspec/rails/tasks/rspec.rake"

# Default
# -----------------------------------------------------------------------------
Rake::Task["default"].prerequisites.clear
Rake::Task["default"].clear

task :default => [:spec, :teabag]

# Teabag
# -----------------------------------------------------------------------------
load File.expand_path("../lib/tasks/teabag.rake", __FILE__)

namespace :teabag do
  desc "Builds Teabag into the distribution ready bundle"
  task :build => ['build:javascripts']

  namespace :build do

    desc "Compile coffeescripts into javacripts"
    task :javascripts => :environment do
      env = Rails.application.assets

      ['teabag/jasmine.js', 'teabag/mocha.js'].each do |path|
        asset = env.find_asset(path)
        asset.write_to(Teabag::Engine.root.join("app/assets/javascripts/#{path.gsub(/\//, '-')}"))
      end
    end
  end
end
