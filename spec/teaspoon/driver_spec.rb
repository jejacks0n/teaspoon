require "spec_helper"
require "teaspoon/driver/base"

describe Teaspoon::Driver do
  subject { described_class }

  before do
    @driver_file = create_loadable_file("my_driver.rb", <<-DRIVER)
      module MyDriver
        module DeeplyNested
          class SomethingNew < Teaspoon::Driver::Base
          end
        end
      end
    DRIVER

    described_class.register(
      :my_driver,
      "MyDriver::DeeplyNested::SomethingNew",
      "my_driver"
    )
  end

  after do
    cleanup_loadable_file(@driver_file)
  end

  describe ".fetch" do
    let(:my_driver) { MyDriver::DeeplyNested::SomethingNew }
    it "returns the driver class to be used" do
      expect(subject.fetch(:my_driver)).to eq(my_driver)
    end

    it "converts strings to symbols for backwards compatibility" do
      expect(subject.fetch("my_driver")).to eq(my_driver)
    end

    it "converts dashes to underscores for backwards compatibility" do
      expect(subject.fetch("my-driver")).to eq(my_driver)
    end

    it "raises an exception when an unknown driver is being used" do
      expect { subject.fetch(:bad_driver) }.to raise_error(
        Teaspoon::UnknownDriver,
        /Unknown driver: expected "bad_driver" to be a registered driver. Available drivers are \[.*:my_driver.*\]/
      )
    end
  end

  describe ".equal?" do
    it "determines if the two conditions are equal after processing" do
      expect(Teaspoon::Driver.equal?(:capybara_webkit, :capybara_webkit)).to equal(true)
      expect(Teaspoon::Driver.equal?(:capybara_webkit, "capybara-webkit")).to equal(true)
      expect(Teaspoon::Driver.equal?("capybara-webkit", :capybara_webkit)).to equal(true)
      expect(Teaspoon::Driver.equal?(:capybara_webkit, :phantomjs)).to equal(false)
    end
  end
end
