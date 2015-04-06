require "spec_helper"

describe "Calling hooks" do
  let(:app) { Dummy::Application }

  before do
    @expected = nil
    set_teaspoon_suite do |c|
      c.javascripts = [""]
      c.hook(:before) { @expected = "before" }
      c.hook(:after) { @expected = "after" }
      c.hook(:with_params) { |params| @expected = "with_params: #{params.to_json}" }
    end
  end

  it "allows calling them by name" do
    post "/teaspoon/default/before"
    expect(@expected).to eq("before")

    post "/teaspoon/default/after"
    expect(@expected).to eq("after")
  end

  it "allows providing params" do
    post "/teaspoon/default/with_params", args: { message: "_teaspoon_hook_" }
    expect(@expected).to eq('with_params: {"message":"_teaspoon_hook_"}')
  end
end
