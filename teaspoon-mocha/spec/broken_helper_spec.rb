require_relative "./spec_helper"

feature "Broken helper", shell: true do
  let(:version) do
    Teaspoon::Framework.fetch(:mocha).versions.last
  end

  before do
    teaspoon_test_app(<<-GEMFILE)
      gem 'teaspoon', path: '#{Teaspoon::DEV_PATH}'
      gem 'teaspoon-mocha', path: '#{Teaspoon::DEV_PATH}'
    GEMFILE
    install_teaspoon("--coffee --version=#{version}")
    copy_broken_helper("spec")
  end

  it "displays error messages and fails using the CLI" do
    run_teaspoon("--no-color")
    expect(last_command_started).to have_exit_status(1)
    expect(teaspoon_output).to match("ReferenceError: Can't find variable: i_will_not_exist")
  end
end
