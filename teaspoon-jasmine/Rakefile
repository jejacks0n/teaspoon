#!/usr/bin/env rake

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "teaspoon-devkit"

Teaspoon.load_teaspoon_tasks

Teaspoon.setup_framework_tasks(
  framework: :jasmine,
  framework_name: "Jasmine",
  framework_root: File.expand_path(File.dirname(__FILE__)),
  framework_env: File.expand_path("spec/teaspoon_env.rb", File.dirname(__FILE__)),
  framework_const: Teaspoon::Framework.fetch(:jasmine),
  compile_assets: ["jasmine1.js", "jasmine2.js"]
)
