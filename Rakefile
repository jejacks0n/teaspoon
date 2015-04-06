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
ENV["TEASPOON_RAILS_ENV"] = File.expand_path("../spec/dummy/config/environment.rb", __FILE__)
load "rails/tasks/engine.rake"
begin
  Bundler::GemHelper.install_tasks
rescue RuntimeError
  Bundler::GemHelper.install_tasks name: "teaspoon"
end

# RSpec
# -----------------------------------------------------------------------------
load "rspec/rails/tasks/rspec.rake"

namespace :spec do
  desc "Run the unit code examples"
  RSpec::Core::RakeTask.new(:unit) do |t|
    file_list = FileList["spec/**/*_spec.rb"]
    %w(features).each do |exclude|
      file_list = file_list.exclude("spec/#{exclude}/**/*_spec.rb")
    end
    t.pattern = file_list
  end

  desc "Run the code examples in teaspoon-jasmine/spec"
  RSpec::Core::RakeTask.new(:jasmine) do |t|
    t.pattern = "../teaspoon-jasmine/spec/**/*_spec.rb"
  end

  desc "Run the code examples in teaspoon-mocha/spec"
  RSpec::Core::RakeTask.new(:mocha) do |t|
    t.pattern = "../teaspoon-mocha/spec/**/*_spec.rb"
  end

  desc "Run the code examples in teaspoon-qunit/spec"
  RSpec::Core::RakeTask.new(:qunit) do |t|
    t.pattern = "../teaspoon-qunit/spec/**/*_spec.rb"
  end
end

# Teaspoon
# -----------------------------------------------------------------------------
desc "Run the javascript specs"
task teaspoon: "app:teaspoon"

# namespace :teaspoon do
#   desc "Builds Teaspoon into the distribution ready bundle"
#   task build: "build:javascripts"
#
#   namespace :build do
#     desc "Compile coffeescripts into javacripts"
#     task javascripts: :environment do
#       env = Rails.application.assets
#
#       %w(jasmine1.js jasmine2.js mocha.js qunit.js teaspoon.js).each do |path|
#         asset = env.find_asset("teaspoon/"#{path}"")
#         asset.write_to(Teaspoon::Engine.root.join("app/assets/javascripts/teaspoon-#{path}"))
#       end
#     end
#   end
# end

# Default
# -----------------------------------------------------------------------------
Rake::Task["default"].prerequisites.clear
Rake::Task["default"].clear

task default: [
  # core
  :spec,
  :teaspoon,
  # teaspoon-jasmine
  "spec:jasmine",
  # teaspoon-mocha
  "spec:mocha",
  # teaspoon-qunit
  "spec:qunit",
]
