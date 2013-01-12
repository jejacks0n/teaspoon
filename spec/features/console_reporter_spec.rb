require "spec_helper"

feature "testing with teabag in the console", aruba: true do

  scenario "gives me the expected results" do
    run_simple("bundle exec teabag -r ../../spec/teabag_env --suite=default app/assets/javascripts/integration/integration_spec.coffee", false)

    assert_partial_output("..F.*.", all_output)
    assert_partial_output("testing console output", all_output)
    assert_partial_output("6 examples, 1 failure, 1 pending", all_output)
    assert_partial_output('teabag -s default --filter="Integration tests allows failing specs."', all_output)

    expected = <<-OUTPUT
Pending:
  Integration tests pending is allowed
    # Not yet implemented

Failures:

  1) Integration tests allows failing specs
     Failure/Error: Expected true to be false.
    OUTPUT
    assert_partial_output(expected, all_output)
  end
end
