require "spec_helper"

describe Teaspoon::Drivers do
  let!(:my_driver) do
    Class.new(Teaspoon::Drivers::Base) do
      register_driver :my_driver
    end
  end

  describe ".fetch" do
    it "returns the driver class to be used" do
      expect(Teaspoon::Drivers.fetch(:my_driver)).to eq(my_driver)
    end

    it "converts strings to symbols for backwards compatibility" do
      expect(Teaspoon::Drivers.fetch("my_driver")).to eq(my_driver)
    end

    it "raises an exception when an unknown driver is being used" do
      expect { Teaspoon::Drivers.fetch("bad_driver") }.to raise_error(
        Teaspoon::UnknownDriver,
        /Unknown driver: expected "bad_driver" to be a registered driver. Available drivers are \[.*:my_driver.*\]/
      )
    end
  end
end
