#!/usr/bin/env rake
require "fileutils"

frameworks = [:jasmine, :mocha, :qunit]

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
end

# Teaspoon
# -----------------------------------------------------------------------------
desc "Run the javascript specs"
task teaspoon: "app:teaspoon"

namespace :teaspoon do
  desc "Builds Teaspoon into the distribution ready bundle"
  task build: "build:javascripts"

  namespace :build do
    desc "Builds all frameworks into the distribution ready bundles"
    compile_tasks = frameworks.inject([]) do |tasks, framework|
      tasks + ["teaspoon:#{framework}:build"]
    end
    task javascripts: compile_tasks
  end
end

# Default
# -----------------------------------------------------------------------------
Rake::Task["default"].prerequisites.clear
Rake::Task["default"].clear

default_tasks = [:spec, :teaspoon]
frameworks.each do |framework|
  default_tasks << "teaspoon:#{framework}:spec"
  default_tasks << "teaspoon:#{framework}:jsspec"
end

task default: default_tasks

if Teaspoon.loaded_from_teaspoon_root?
  frameworks.each do |framework|
    load File.expand_path("teaspoon-#{framework}/Rakefile", File.expand_path(File.dirname(__FILE__)))
  end
end
