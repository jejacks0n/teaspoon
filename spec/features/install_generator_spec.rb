require "spec_helper"

feature "installing teabag with the generator", aruba: true do

  before do
    unset_bundler_env_vars
    run_simple("bundle exec rails new testapp --skip-bundle")
    cd("testapp")
    append_to_file("Gemfile", %{\ngem "teabag", path: "#{File.expand_path('../../../', __FILE__)}"\n})
    run_simple("bundle install --local")
  end

  scenario "installs the basic files" do
    run_simple("bundle exec rails generate teabag:install --trace")
    expected = <<-OUTPUT
      create  config/initializers/teabag.rb
      create  spec/teabag_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.js
    OUTPUT
    assert_partial_output(expected, all_output)
    check_file_presence(["config/initializers/teabag.rb"], true)
    check_file_presence(["spec/teabag_env.rb"], true)
    check_file_presence(["spec/javascripts/spec_helper.js"], true)
  end

  scenario "installs with coffeescript spec helpers" do
    run_simple("bundle exec rails generate teabag:install --trace --coffee")
    expected = <<-OUTPUT
      create  spec/javascripts/spec_helper.coffee
    OUTPUT
    assert_partial_output(expected, all_output)
    check_file_presence(["config/initializers/teabag.rb"], true)
  end

  scenario "allows installing using the mocha framework" do
    run_simple("bundle exec rails generate teabag:install --trace --framework=mocha")
    check_file_content("config/initializers/teabag.rb", %{    suite.javascripts = ["teabag-mocha"]}, true)
  end
end
