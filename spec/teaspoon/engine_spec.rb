require "spec_helper"

describe Teaspoon::Engine do

  it "is a class" do
    Teaspoon::Engine.should be_a(Class)
  end

  it "has been isolated with a name" do
    expect(Teaspoon::Engine.isolated?).to be(true)
    expect(Teaspoon::Engine.railtie_name).to eql("teaspoon")
  end

  it "adds asset paths from configuration" do
    expect(Rails.application.config.assets.paths).to include(Teaspoon.configuration.root.join("spec/javascripts").to_s)
    expect(Rails.application.config.assets.paths).to include(Teaspoon.configuration.root.join("spec/javascripts/stylesheets").to_s)
  end

end
