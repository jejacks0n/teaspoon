require "spec_helper"

feature "testing with teabag in the browser", js: true do

  before do
    Teabag.configuration.stub(:suites).and_return "integration" => proc{ |suite|
      suite.matcher = "spec/dummy/app/assets/javascripts/integration/*_spec.{js,js.coffee,coffee}"
      suite.helper = nil
    }
  end

  scenario "gives me the expected results" do
    visit "/teabag/integration"

    within("#teabag-progress") do
      expect(find("em")).to have_text("100%")
    end

    within("#teabag-stats") do
      expect(find("li:nth-child(1)")).to have_text("passes: 4")
      expect(find("li:nth-child(2)")).to have_text("failures: 1")
      expect(find("li:nth-child(3)")).to have_text("skipped: 1")
    end

    within("#teabag-report-failures") do
      expect(find("li.spec")).to have_text("Integration tests allows failing specs.")
    end

    expect(find("#spec_helper_el")).to have_text("this was generated by the spec_helper")
  end
end
