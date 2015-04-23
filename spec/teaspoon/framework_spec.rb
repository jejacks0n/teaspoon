require "spec_helper"

describe Teaspoon::Framework do
  subject { described_class }

  describe ".default" do
    it "returns the framework that was registered first" do
      expect(subject.default).to eq(:jasmine)
    end

    describe "with no frameworks registered" do
      before do
        @frameworks = subject.instance_variable_get(:@options)
        subject.instance_variable_set(:@options, {})
      end

      after do
        subject.instance_variable_set(:@options, @frameworks)
      end

      it "returns nil if no frameworks are registered" do
        expect(subject.default).to eq(nil)
      end
    end
  end
end
