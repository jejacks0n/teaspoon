require "spec_helper"

feature "instrumenting javascript" do

  before do
    pending("needs istanbul to be installed") unless Teaspoon::Instrumentation.executable
  end

  scenario "requesting with instrument=true adds istanbul instrumentation" do
    pending("needs to be figured out")
    visit "/assets/instrumented1.js?instrument=true"
    expect(html).to include("if (typeof __coverage__ === 'undefined') { __coverage__ = {}; }")
  end

  scenario "requesting without instrument=true doesn't do anything" do
    pending("needs to be figured out")
    visit "/assets/instrumented2.js?instrument=false"
    expect(html).to_not include("if (typeof __coverage__ === 'undefined') { __coverage__ = {}; }")
  end

end
