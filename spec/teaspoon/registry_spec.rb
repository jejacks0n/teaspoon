require "spec_helper"

describe Teaspoon::Registry do
  subject do
    Class.new do
      extend Teaspoon::Registry
    end
  end

  before do
    @driver_file = create_loadable_file("my_driver.rb", <<-DRIVER)
      module MyDriver
        module DeeplyNested
          class SomethingNew < Teaspoon::Driver::Base
          end
        end
      end
    DRIVER

    subject.register(
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
    it "returns the loaded module stored in the registry" do
      expect(subject.fetch(:my_driver)).to eq(my_driver)
    end

    it "converts strings to symbols for backwards compatibility" do
      expect(subject.fetch("my_driver")).to eq(my_driver)
    end

    it "converts dashes to underscores for backwards compatibility" do
      expect(subject.fetch("my-driver")).to eq(my_driver)
    end

    it "raises an exception when an unknown constant is being fetched" do
      expect { subject.fetch(:bad_driver) }.to raise_error(
        Teaspoon::NotFoundInRegistry,
        /Unknown configuration: expected "bad_driver" to be registered. Available options are \[.*:my_driver.*\]/
      )
    end

    context "with a registered exception class" do
      let(:exception_klass) do
        Class.new(Exception) do
          def initialize(*args)
            super("Not in registry.")
          end
        end
      end

      subject do
        ex_klass = exception_klass
        Class.new do
          extend Teaspoon::Registry

          not_found_in_registry ex_klass
        end
      end

      it "raises the custom exception when an unknown constant is being fetched" do
        expect { subject.fetch(:bad_driver) }.to raise_error(
          exception_klass,
          "Not in registry."
        )
      end
    end
  end

  describe ".equal?" do
    it "determines if the two conditions are equal after processing" do
      expect(subject.equal?(:capybara_webkit, :capybara_webkit)).to equal(true)
      expect(subject.equal?(:capybara_webkit, "capybara-webkit")).to equal(true)
      expect(subject.equal?("capybara-webkit", :capybara_webkit)).to equal(true)
      expect(subject.equal?(:capybara_webkit, :phantomjs)).to equal(false)
    end
  end

  describe ".available" do
    it "lists the registered options with any arbitrary data passed to #register" do
      subject.register(:his_driver,"","my_driver", extra: "data", default: true)
      subject.register(:her_driver,"","my_driver")

      expect(subject.available).to eq({
        my_driver: {},
        his_driver: {extra: "data", default: true},
        her_driver: {}
      })
    end
  end
end
