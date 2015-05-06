require_relative "./spec_helper"

feature "Installation", shell: true do
  before do
    teaspoon_test_app(<<-GEMFILE)
      gem 'teaspoon', path: '#{Teaspoon::DEV_PATH}'
      gem 'teaspoon-qunit', path: '#{Teaspoon::DEV_PATH}'
    GEMFILE
  end

  it "installs the expected files" do
    install_teaspoon

    expect(all_output).to include(<<-OUTPUT)
      create  test/teaspoon_env.rb
      create  test/javascripts/support
      create  test/javascripts/fixtures
      create  test/javascripts/test_helper.js
    OUTPUT

    check_file_content("test/teaspoon_env.rb", /suite\.use_framework :qunit, "\d+\.\d+\.\d+"/)
    check_file_content("test/javascripts/test_helper.js", Regexp.new("require support/your-support-file"))
  end

  it "can install coffeescript and the teaspoon_env without comments" do
    install_teaspoon("--coffee --no-comments")

    expect(all_output).to include(<<-OUTPUT)
      create  test/teaspoon_env.rb
      create  test/javascripts/support
      create  test/javascripts/fixtures
      create  test/javascripts/test_helper.coffee
    OUTPUT

    check_file_content("test/teaspoon_env.rb", /suite\.use_framework :qunit, "\d+\.\d+\.\d+"/)
    check_file_content("test/javascripts/test_helper.coffee", Regexp.new("require support/your-support-file"))
  end
end
