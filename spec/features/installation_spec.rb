require "spec_helper"

feature "Installation", shell: true do
  before do
    teaspoon_test_app("gem 'teaspoon', path: '#{Teaspoon::DEV_PATH}'")
  end

  it "errors with the expected message" do
    run_command_and_stop("bundle exec rails generate teaspoon:install --trace", fail_on_error: false)

    expect(last_command_started).to have_exit_status(1)
    expect(all_output).to include(<<-OUTPUT.strip_heredoc)
      ******************************************************************************
      Error: There don't seem to be any frameworks registered within Teaspoon yet.

      Teaspoon has been split into separate gems so you can now include only the
      javascript frameworks you want.

      Add one or more of the following to your gemfile:

        gem "teaspoon-jasmine"
        gem "teaspoon-mocha"
        gem "teaspoon-qunit"

      More information can be found at: https://github.com/jejacks0n/teaspoon
    OUTPUT
  end
end
