require "spec_helper"

describe Teaspoon::Formatter do
  subject { described_class }

  describe ".default" do
    it "returns the registered module with default set to true" do
      expect(subject.default).to eq(:dot)
    end
  end
end
