require "spec_helper"

describe Teabag::Engine do

  it "is a class" do
    Teabag::Engine.should be_a(Class)
  end

  it "has been isolated with a name" do
    expect(Teabag::Engine.isolated?).to be(true)
    expect(Teabag::Engine.railtie_name).to eql("teabag")
  end

  it "adds asset paths from configuration" do
    expect(Rails.application.config.assets.paths).to include(Teabag.configuration.root.join("spec/javascripts").to_s)
    expect(Rails.application.config.assets.paths).to include(Teabag.configuration.root.join("spec/javascripts/stylesheets").to_s)
  end

  it "adds the instrumentation post processor" do
    expect(Rails.application.assets.postprocessors('application/javascript')).to include(Teabag::Instrumentation)
  end

end
