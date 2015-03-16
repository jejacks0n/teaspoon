require "aruba/api"

module Teaspoon
  module Devkit
    def set_teaspoon_suite(name = "default", &block)
      suites = {}
      suites[name] = { block: block }
      Teaspoon::Suite.instance_variable_set(:@all, nil)
      allow(Teaspoon.configuration).to receive(:suite_configs).and_return(suites)
    end

    include Aruba::Api

    def teaspoon_test_app(gem = '', local = false)
      set_env("TEASPOON_ENV", nil)
      unset_bundler_env_vars

      # create the rails application
      run_simple("bundle exec rails new testapp --skip-bundle --skip-activerecord")
      cd("testapp")

      # append teaspoon to the gemfile and bundle
      append_to_file("Gemfile", %{\n#{gem}\n})
      run_simple("bundle install#{local ? ' --local' : ''}")
    end

    def install_teaspoon(opts = "")
      run_simple("bundle exec rails generate teaspoon:install #{opts} --trace")
    end

    def run_teaspoon(opts = "")
      run_simple("bundle exec teaspoon #{opts}", false)
    end

    def rake_teaspoon(envs = "")
      run_simple("bundle exec rake teaspoon #{envs}", false)
    end

    def copy_integration_files(suffix, from, to = "spec")
      sources = Dir[File.join(from, "javascripts", "integration", "**/*")]
      dest = File.join(current_dir, File.join(to, "javascripts/integration"))
      FileUtils::mkdir_p(dest)
      sources.each do |source|
        spec = File.join(dest, File.basename(source).gsub("_integration", "_#{suffix}"))
        FileUtils.cp(source, spec)
      end
    end

    def teaspoon_output
      output = all_output.gsub(/127\.0\.0\.1:\d+/, "127.0.0.1:31337")
      output = output.gsub(/Finished in [\d\.]+ seconds/, "Finished in 0.31337 seconds")
      output
    end
  end
end
