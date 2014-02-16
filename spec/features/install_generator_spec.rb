require "spec_helper"

feature "Installation", aruba: true do

  before do
    unset_bundler_env_vars
    run_simple("bundle exec rails new testapp --skip-bundle")
    cd("testapp")
    append_to_file("Gemfile", %{\ngem "teaspoon", path: "#{File.expand_path('../../../', __FILE__)}"\n})
    run_simple("bundle install --local")
  end

  describe "running the generator" do

    scenario "installs the basic files" do
      run_simple("bundle exec rails generate teaspoon:install --trace")

      expected = <<-OUTPUT
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.js
      OUTPUT
      assert_partial_output(expected, all_output)

      check_file_presence(["spec/teaspoon_env.rb"], true)
      check_file_presence(["spec/javascripts/spec_helper.js"], true)
    end

  end

  describe "specifying options" do

    scenario "installs with coffeescript spec helpers" do
      run_simple("bundle exec rails generate teaspoon:install --trace --coffee")

      expected = <<-OUTPUT
      create  spec/javascripts/spec_helper.coffee
      OUTPUT
      assert_partial_output(expected, all_output)

      check_file_presence(["spec/teaspoon_env.rb"], true)
      check_file_presence(["spec/javascripts/spec_helper.coffee"], true)
    end

    scenario "installs using the mocha framework" do
      run_simple("bundle exec rails generate teaspoon:install --trace --framework=mocha")

      check_file_content("spec/teaspoon_env.rb", %{    suite.use_framework :mocha}, true)
      check_file_content("spec/teaspoon_env.rb", %{    #suite.javascripts = ["mocha/1.17.1", "teaspoon-mocha"]}, true)
    end

  end

end
