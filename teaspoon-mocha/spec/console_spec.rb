require_relative "./spec_helper"

feature "Running in the console", shell: true do
  let(:expected_output) do
    <<-OUTPUT.strip_heredoc
      Starting the Teaspoon server...
      Teaspoon running default suite at http://127.0.0.1:31337/teaspoon/default
      TypeError: undefined is not a constructor (evaluating 'foo()')
        # integration/spec_helper.js:12

      FFit can log to the console
      .**.

      Pending:
        Integration tests with nested describes allows pending specs using xit
          # Not yet implemented

        Integration tests with nested describes allows pending specs using no function
          # Not yet implemented

      Failures:

        1) Integration tests allows failing specs
           Failure/Error: expected true to sort of equal false

        2) Integration tests allows erroring specs
           Failure/Error: Can't find variable: foo

      Finished in 0.31337 seconds
      6 examples, 2 failures, 2 pending

      Failed examples:

      teaspoon -s default --filter="Integration tests allows failing specs"
      teaspoon -s default --filter="Integration tests allows erroring specs"
    OUTPUT
  end

  before do
    teaspoon_test_app("gem 'teaspoon-mocha', path: '#{Teaspoon::DEV_PATH}'", true)
    install_teaspoon("--coffee")
    copy_integration_files("spec", File.expand_path("../", __FILE__))
  end

  it "runs successfully using the CLI" do
    run_teaspoon("--no-color")

    expect(teaspoon_output).to include(expected_output)
  end

  it "runs successfully using the rake task" do
    rake_teaspoon("COLOR=false")

    expect(teaspoon_output).to include(expected_output)
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
