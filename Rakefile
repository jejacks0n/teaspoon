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
begin
  Bundler::GemHelper.install_tasks
rescue RuntimeError
  Bundler::GemHelper.install_tasks name: 'teaspoon'
end

# RSpec
# -----------------------------------------------------------------------------
load "rspec/rails/tasks/rspec.rake"

# Teaspoon
# -----------------------------------------------------------------------------
desc "Run the javascript specs"
task teaspoon: "app:teaspoon"

namespace :teaspoon do
  desc "Builds Teaspoon into the distribution ready bundle"
  task build: "build:javascripts"

  namespace :build do
    desc "Compile coffeescripts into javacripts"
    task javascripts: :environment do
      env = Rails.application.assets

      %w(teaspoon/jasmine.js teaspoon/jasmine2.js teaspoon/mocha.js teaspoon/qunit.js teaspoon/teaspoon.js).each do |path|
        asset = env.find_asset(path)
        asset.write_to(Teaspoon::Engine.root.join("app/assets/javascripts/#{path.gsub(/\//, '-')}"))
      end
    end
  end
end

# Default
# -----------------------------------------------------------------------------
Rake::Task["default"].prerequisites.clear
Rake::Task["default"].clear

task default: [:spec, :teaspoon]
