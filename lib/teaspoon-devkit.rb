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

  def self.loaded_from_teaspoon_root?
    Dir.pwd == DEV_PATH
  end

  def self.load_teaspoon_tasks
    if !loaded_from_teaspoon_root?
      load File.join(RAKEFILE)
    end
  end

  def self.setup_framework_tasks(framework:, framework_name:, framework_const:, framework_root:, compile_assets:)
    extend Rake::DSL

    namespace :teaspoon do
      namespace framework do
        desc "Run the #{framework_name} code examples"
        RSpec::Core::RakeTask.new(:spec) do |t|
          t.pattern = File.expand_path("spec/**/*_spec.rb", framework_root)
        end
      end

      namespace framework do
        desc "Builds Teaspoon #{framework_name} into the distribution ready bundle"
        task build: "#{framework}:build:javascripts"

        namespace :build do
          desc "Compile Teaspoon #{framework_name} coffeescripts into javacripts"
          task javascripts: :environment do
            env = Rails.application.assets

            Array(compile_assets).each do |filename|
              asset = env.find_asset("teaspoon/#{filename}")
              base_destination = framework_const.asset_paths.first
              asset.write_to(File.expand_path("teaspoon-#{filename}", base_destination))
            end
          end
        end
      end
    end

    if !loaded_from_teaspoon_root?
      Rake::Task["default"].prerequisites.clear
      Rake::Task["default"].clear

      task default: "teaspoon:#{framework}:spec"
    end
  end
end
