require "spec_helper"

describe Teaspoon::Engine do

  subject { Teaspoon::Engine }

  it "has been isolated with a name" do
    expect(subject.isolated?).to be(true)
    expect(subject.railtie_name).to eql("teaspoon")
  end

  it "defaults the root path" do
    # this has to add spec/dummy as we set it manually
    expect(Teaspoon.configuration.root.join('spec/dummy').to_s).to eq(Rails.root.to_s)
  end

  it "adds asset paths from configuration" do
    expect(Rails.application.config.assets.paths).to include(Teaspoon.configuration.root.join("spec/javascripts").to_s)
    expect(Rails.application.config.assets.paths).to include(Teaspoon.configuration.root.join("spec/javascripts/stylesheets").to_s)
  end

end
