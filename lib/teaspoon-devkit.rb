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

  def self.setup_framework_tasks(options)
    extend Rake::DSL

    framework = options[:framework]
    framework_name = options[:framework_name]
    framework_const = options[:framework_const]
    framework_root = options[:framework_root]
    framework_env = options[:framework_env]
    compile_assets = options[:compile_assets]

    namespace :teaspoon do
      namespace framework do
        desc "Run the #{framework_name} code examples"
        RSpec::Core::RakeTask.new(:spec) do |t|
          t.pattern = File.expand_path("spec/**/*_spec.rb", framework_root)
        end

        desc "Run the #{framework_name} javascript tests"
        task :jsspec do
          rails_env = File.expand_path("spec/dummy/config/environment.rb", DEV_PATH)
          cmd = "rake teaspoon TEASPOON_DEVELOPMENT=true TEASPOON_RAILS_ENV=#{rails_env} TEASPOON_ENV=#{framework_env}"

          # we shell out to another command so that it creates a pristine runtime environment
          IO.popen(cmd).each do |line|
            STDOUT.print(line)
          end.close

          exit(1) unless $?.success?
        end

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

      task default: ["teaspoon:#{framework}:spec", "teaspoon:#{framework}:jsspec"]
    end
  end
end
