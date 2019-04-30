begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

# define the supported frameworks
frameworks = [:jasmine, :mocha, :qunit]

# setup the dummy app
APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
ENV["TEASPOON_RAILS_ENV"] = File.expand_path("../spec/dummy/config/environment.rb", __FILE__)
load "rails/tasks/engine.rake"

# useful bundler gem tasks
begin
  Bundler::GemHelper.install_tasks
rescue RuntimeError
  Bundler::GemHelper.install_tasks name: "teaspoon"
end

# load in rspec tasks
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

# teaspoon build tasks
namespace :teaspoon do
  desc "Builds Teaspoon into the distribution ready bundle"
  task build: ["teaspoon:build:javascripts"]

  namespace :build do
    desc "Builds all frameworks into the distribution ready bundles"
    task javascripts: (frameworks.inject([]) do |tasks, framework|
      tasks + ["teaspoon:#{framework}:build"]
    end)
  end
end

# add in the javascript library gems
if Teaspoon.loaded_from_teaspoon_root?
  frameworks.each do |framework|
    load File.expand_path("../teaspoon-#{framework}/Rakefile", __FILE__)
  end
end

# move teaspoon up from app:teaspoon
desc "Run the javascript specs"
task teaspoon: "app:teaspoon"

# setup the default task
Rake::Task["default"].prerequisites.clear
Rake::Task["default"].clear

task default: (frameworks.inject([:spec, :teaspoon]) do |tasks, framework|
  tasks + ["teaspoon:#{framework}:spec", "teaspoon:#{framework}:jsspec"]
end)
