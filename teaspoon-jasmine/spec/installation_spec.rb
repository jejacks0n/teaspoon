require_relative "./spec_helper"

feature "Installation", shell: true do
  before do
    teaspoon_test_app("gem 'teaspoon-jasmine', path: '#{Teaspoon::DEV_PATH}'")
  end

  it "installs the expected files" do
    install_teaspoon

    expect(all_output).to include(<<-OUTPUT)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.js
    OUTPUT

    check_file_content("spec/teaspoon_env.rb", /suite\.use_framework :jasmine, "\d+\.\d+\.\d+"/)
    check_file_content("spec/javascripts/spec_helper.js", Regexp.new("require support/your-support-file"))
  end

  it "can install coffeescript and the teaspoon_env without comments" do
    install_teaspoon("--coffee --no-comments")

    expect(all_output).to include(<<-OUTPUT)
      create  spec/teaspoon_env.rb
      create  spec/javascripts/support
      create  spec/javascripts/fixtures
      create  spec/javascripts/spec_helper.coffee
    OUTPUT

    check_file_content("spec/teaspoon_env.rb", /suite\.use_framework :jasmine, "\d+\.\d+\.\d+"/)
    check_file_content("spec/javascripts/spec_helper.coffee", Regexp.new("require support/your-support-file"))
  end
end
