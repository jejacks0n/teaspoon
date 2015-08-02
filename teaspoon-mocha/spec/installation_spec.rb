require_relative "./spec_helper"

feature "Installation", shell: true do
  before do
    teaspoon_test_app(<<-GEMFILE)
      gem 'teaspoon', path: '#{Teaspoon::DEV_PATH}'
      gem 'teaspoon-mocha', path: '#{Teaspoon::DEV_PATH}'
    GEMFILE
  end

  it "installs the expected files" do
    install_teaspoon

    expect(all_output).to include(<<-OUTPUT)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.js
    OUTPUT

    expect("spec/teaspoon_env.rb").to have_file_content(/suite\.use_framework :mocha, "\d+\.\d+\.\d+"/)
    expect("spec/javascripts/spec_helper.js").to have_file_content(Regexp.new("require support/your-support-file"))
  end

  it "can install coffeescript and the teaspoon_env without comments" do
    install_teaspoon("--coffee --no-comments")

    expect(all_output).to include(<<-OUTPUT)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.coffee
    OUTPUT

    expect("spec/teaspoon_env.rb").to have_file_content(/suite\.use_framework :mocha, "\d+\.\d+\.\d+"/)
    expect("spec/javascripts/spec_helper.coffee").to have_file_content(Regexp.new("require support/your-support-file"))
  end
end
