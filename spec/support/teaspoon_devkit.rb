require "aruba/api"

module Teaspoon
  module Devkit
    def set_teaspoon_suite(name = "default", &block)
      suites = {}
      suites[name.to_s] = { block: block }
      Teaspoon::Suite.instance_variable_set(:@all, nil)
      allow(Teaspoon.configuration).to receive(:suite_configs).and_return(suites)
    end

    include Aruba::Api

    def teaspoon_test_app(gem = "", local = !ENV["TRAVIS"])
      set_environment_variable("TEASPOON_ENV", nil)

      # Create the Rails application, which uses the version of Rails defined
      # in the Appraisal Gemfile. Then, no longer use the Appraisal Gemfile
      # and use the application one instead.
      run_simple("bundle exec rails new testapp --skip-bundle --skip-activerecord -O --skip-javascript --skip-gemfile")
      cd("testapp")
      set_environment_variable("BUNDLE_GEMFILE", expand_path("Gemfile"))

      # append to the gemfile base dependencies and teaspoon and bundle
      append_to_file("Gemfile", %{\ngem "rails", "#{Rails.version}"\n})
      # coffee-rails is needed because we are using Teaspoon dev deps which are CS files
      append_to_file("Gemfile", %{\ngem "coffee-rails"\n})
      append_to_file("Gemfile", %{\n#{gem}\n})
      run_simple("bundle install#{local ? ' --local' : ''}")

      # create an application.js because there is no way to tell rails not to include it
      # in the layout, and we don't want the default generated application.js
      touch("app/assets/javascripts/application.js")
    end

    def install_teaspoon(opts = "")
      run_simple("bundle exec rails generate teaspoon:install #{opts} --trace")
    end

    def run_teaspoon(opts = "")
      set_rails_env
      run_simple("bundle exec teaspoon #{opts}", false)
    end

    def rake_teaspoon(envs = "")
      set_rails_env
      run_simple("bundle exec rake teaspoon #{envs}", false)
    end

    def copy_integration_files(suffix, from, to = "spec")
      sources = Dir[File.join(from, "javascripts", "integration", "**/*")]
      dest = expand_path(File.join(to, 'javascripts/integration'))
      FileUtils::mkdir_p(dest)
      sources.each do |source|
        spec = File.join(dest, File.basename(source).gsub("_integration", "_#{suffix}"))
        FileUtils.cp(source, spec)
      end
    end

    def teaspoon_output
      output = all_output.gsub(/127\.0\.0\.1:\d+/, "127.0.0.1:31337")
      output = output.gsub("'undefined' is not a function", "undefined is not a constructor")
      output = output.gsub(/Finished in [\d\.]+ seconds/, "Finished in 0.31337 seconds")
      output
    end

    def set_rails_env
      boot_from = expand_path("config/environment.rb")
      set_environment_variable("TEASPOON_RAILS_ENV", boot_from)
    end
  end
end
