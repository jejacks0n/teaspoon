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

    expect("test/teaspoon_env.rb").to have_file_content(/suite\.use_framework :qunit, "\d+\.\d+\.\d+"/)
    expect("test/javascripts/test_helper.js").to have_file_content(Regexp.new("require support/your-support-file"))
  end

  it "can install coffeescript and the teaspoon_env without comments" do
    install_teaspoon("--coffee --no-comments")

    expect(all_output).to include(<<-OUTPUT)
      create  test/teaspoon_env.rb
      create  test/javascripts/support
      create  test/javascripts/fixtures
      create  test/javascripts/test_helper.coffee
    OUTPUT

    expect("test/teaspoon_env.rb").to have_file_content(/suite\.use_framework :qunit, "\d+\.\d+\.\d+"/)
    expect("test/javascripts/test_helper.coffee").to have_file_content(Regexp.new("require support/your-support-file"))
  end
end
