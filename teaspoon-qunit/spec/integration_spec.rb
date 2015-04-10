require_relative "./spec_helper"

feature "Running in the browser", browser: true do
  before do
    path = File.expand_path("../../test/javascripts", __FILE__)
    set_teaspoon_suite do |c|
      c.use_framework :qunit
      c.matcher = "#{path}/**/*_integration.{js,js.coffee,coffee}"
    end
  end

  describe "when on the suites page" do
    it "lists the suites" do
      visit "/teaspoon"

      within("#teaspoon-suite-list") do
        expect(page).to have_text("default")
        expect(page).to have_text("first_integration.js")
        expect(page).to have_text("second_integration.js")
      end
    end
  end

  describe "when running specs" do
    it "generates the expected results" do
      visit "/teaspoon/default"

      within("#teaspoon-progress") do
        expect(find("em")).to have_text("100%")
      end

      within("#teaspoon-stats") do
        expect(find("li:nth-child(1)")).to have_text("passes: 2")
        expect(find("li:nth-child(2)")).to have_text("failures: 3")
        expect(find("li:nth-child(3)")).to have_text("skipped: 0")
      end

      within("#teaspoon-report-failures") do
        expect(find("li.spec:nth-child(1)")).
          to have_text("global failure TypeError: foo is not a function")
        expect(find("li.spec:nth-child(2)")).
          to have_text("Integration tests allows failing specs fails correctly")
      end
    end

    it "allows toggling the progress indicator" do
      visit "/teaspoon/default"

      find("#teaspoon-display-progress").click
      expect(page).not_to have_text("100%")

      find("#teaspoon-display-progress").click
      expect(page).to have_text("100%")
    end

    it "allows toggling full reports" do
      visit "/teaspoon/default"

      expect(page).not_to have_selector("#teaspoon-report-all")

      find("#teaspoon-build-full-report").click
      text = find("#teaspoon-report-all").text
      expect(text).to include("global failure")
      expect(text).to include("Integration tests allows failing specs")
      expect(text).to include("allows erroring specs")
      expect(text).to include("allows passing specs")
      expect(text).to include("Another top level integration test allows passing specs")

      find("#teaspoon-build-full-report").click
      expect(page).not_to have_selector("#teaspoon-report-all")
    end
  end
end
