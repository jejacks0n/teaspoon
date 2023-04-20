require_relative "./spec_helper"

feature "Running in the console", shell: true do
  let(:expected_loading_output) do
    Regexp.new(<<-OUTPUT.strip_heredoc)
      Starting the Teaspoon server...
      Teaspoon running default suite at http://127\\.0\\.0\\.1:31337/teaspoon/default
    OUTPUT
  end

  let(:expected_testing_output) do
    Regexp.new(<<-OUTPUT.strip_heredoc)
      FFit can log to the console
      \\.\\*\\*\\.

      Pending:
        Integration tests with nested describes allows pending specs using xit
          # Not yet implemented

        Integration tests with nested describes allows pending specs using no function
          # Not yet implemented

      Failures:

        1\\) Integration tests allows failing specs
           Failure/Error: expected true to sort of equal false

        2\\) Integration tests allows erroring specs
           Failure/Error: Can't find variable: foo

      Finished in 0\\.31337 seconds
      6 examples, 2 failures, 2 pending

      Failed examples:

      teaspoon -s default --filter="Integration tests allows failing specs"
      teaspoon -s default --filter="Integration tests allows erroring specs"
    OUTPUT
  end

  let(:version) do
    Teaspoon::Framework.fetch(:mocha).versions.last
  end

  before do
    teaspoon_test_app(<<-GEMFILE)
      gem 'teaspoon', path: '#{Teaspoon::DEV_PATH}'
      gem 'teaspoon-mocha', path: '#{Teaspoon::DEV_PATH}'
    GEMFILE
    install_teaspoon("--coffee --version=#{version}")
    copy_integration_files("spec", File.expand_path("../", __FILE__))
  end

  it "runs successfully using the CLI" do
    pending "please fix this test for me." if RUBY_VERSION > "3.0"
    run_teaspoon("--no-color")

    expect(teaspoon_output).to match(expected_loading_output)
    expect(teaspoon_output).to match(expected_testing_output)
  end

  it "runs successfully using the rake task" do
    pending "please fix this test for me." if RUBY_VERSION > "3.0"
    rake_teaspoon("COLOR=false")

    expect(teaspoon_output).to match(expected_loading_output)
    expect(teaspoon_output).to match(expected_testing_output)
  end

  it "can display coverage information" do
    pending("needs istanbul to be installed") unless Teaspoon::Instrumentation.executable
    run_teaspoon("--coverage=default")

    expect(teaspoon_output).to include(<<-COVERAGE.strip_heredoc)
      =============================== Coverage summary ===============================
      Statements   : 75% ( 3/4 )
      Branches     : 100% ( 0/0 )
      Functions    : 50% ( 1/2 )
      Lines        : 75% ( 3/4 )
      ================================================================================
    COVERAGE
  end
end
