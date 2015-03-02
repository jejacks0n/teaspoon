require "spec_helper"

feature "Installation", aruba: true do
  let(:teaspoon_path) { File.expand_path("../../../", __FILE__) }
  let(:bundle) { "bundle install" }

  before do
    unset_bundler_env_vars
    run_simple("bundle exec rails new testapp --skip-bundle")
    cd("testapp")
  end

  describe "standalone without a framework" do

    before do
      append_to_file("Gemfile", %{\ngem "teaspoon", path: "#{teaspoon_path}"\n})
      run_simple(bundle)
      run_simple("bundle exec rails generate teaspoon:install --trace", false)
    end

    it "errors with the expected message" do
      assert_exit_status(1)
      assert_partial_output("Error: There don't seem to be any frameworks registered within Teaspoon yet.", all_output)
    end

  end

  describe "with the jasmine framework" do

    before do
      append_to_file("Gemfile", %{\ngem "teaspoon-jasmine", path: "#{teaspoon_path}"\n})
      run_simple(bundle)
    end

    it "installs the expected files" do
      run_simple("bundle exec rails generate teaspoon:install --trace")

      assert_partial_output(<<-OUTPUT, all_output)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.js
      OUTPUT

      check_file_content("spec/teaspoon_env.rb", Regexp.new("suite.use_framework :jasmine"))
      check_file_content("spec/javascripts/spec_helper.js", Regexp.new("require support/your-support-file"))
    end

    it "can install coffeescript and the teaspoon_env without comments" do
      run_simple("bundle exec rails generate teaspoon:install --trace --coffee --no_comments")

      assert_partial_output(<<-OUTPUT, all_output)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.coffee
      OUTPUT

      check_file_content("spec/teaspoon_env.rb", Regexp.new("suite.use_framework :jasmine"))
      check_file_content("spec/javascripts/spec_helper.coffee", Regexp.new("require support/your-support-file"))
    end

  end

  describe "with the mocha framework" do

    before do
      append_to_file("Gemfile", %{\ngem "teaspoon-mocha", path: "#{teaspoon_path}"\n})
      run_simple(bundle)
    end

    it "installs the expected files" do
      run_simple("bundle exec rails generate teaspoon:install --trace")

      assert_partial_output(<<-OUTPUT, all_output)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.js
      OUTPUT

      check_file_content("spec/teaspoon_env.rb", Regexp.new("suite.use_framework :mocha"))
      check_file_content("spec/javascripts/spec_helper.js", Regexp.new("require support/your-support-file"))
    end

    it "can install coffeescript and the teaspoon_env without comments" do
      run_simple("bundle exec rails generate teaspoon:install --trace --coffee --no_comments")

      assert_partial_output(<<-OUTPUT, all_output)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.coffee
      OUTPUT

      check_file_content("spec/teaspoon_env.rb", Regexp.new("suite.use_framework :mocha"))
      check_file_content("spec/javascripts/spec_helper.coffee", Regexp.new("require support/your-support-file"))
    end

  end

  describe "with the qunit framework" do

    before do
      append_to_file("Gemfile", %{\ngem "teaspoon-qunit", path: "#{teaspoon_path}"\n})
      run_simple(bundle)
    end

    it "installs the expected files" do
      run_simple("bundle exec rails generate teaspoon:install --trace")

      assert_partial_output(<<-OUTPUT, all_output)
      create  test/teaspoon_env.rb
      create  test/javascripts/support
      create  test/javascripts/fixtures
      create  test/javascripts/test_helper.js
      OUTPUT

      check_file_content("test/teaspoon_env.rb", Regexp.new("suite.use_framework :qunit"))
      check_file_content("test/javascripts/test_helper.js", Regexp.new("require support/your-support-file"))
    end

    it "can install coffeescript and the teaspoon_env without comments" do
      run_simple("bundle exec rails generate teaspoon:install --trace --coffee --no_comments")

      assert_partial_output(<<-OUTPUT, all_output)
      create  test/teaspoon_env.rb
      create  test/javascripts/support
      create  test/javascripts/fixtures
      create  test/javascripts/test_helper.coffee
      OUTPUT

      check_file_content("test/teaspoon_env.rb", Regexp.new("suite.use_framework :qunit"))
      check_file_content("test/javascripts/test_helper.coffee", Regexp.new("require support/your-support-file"))
    end

  end
end
