require "spec_helper"

describe Teaspoon::Registry::HasDefault do
  subject do
    Class.new do
      extend Teaspoon::Registry
      extend Teaspoon::Registry::HasDefault
    end
  end

  describe ".default" do
    it "returns the registered module with default set to true" do
      subject.register(:non_default, "", "")
      subject.register(:the_default, "", "", default: true)

      expect(subject.default).to eq(:the_default)
    end
  end
end
