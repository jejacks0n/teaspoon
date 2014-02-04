require "spec_helper"

describe Teaspoon::Drivers::PhantomjsDriver do

  describe "#initialize" do

    it "assigns @options" do
      subject = Teaspoon::Drivers::PhantomjsDriver.new(foo: "bar")
      expect(subject.instance_variable_get(:@options)).to eq(foo: "bar")
    end

  end

  describe "#run_specs" do

    context "with phantomjs" do

      let(:runner) { double }

      before do
        subject.stub(:run)
      end

      it "calls #run and calls runner.process with each line of output" do
        subject.instance_variable_set(:@options, "--foo --bar")
        args = ["--foo", "--bar", Teaspoon::Engine.root.join("lib/teaspoon/drivers/phantomjs/runner.js").to_s, "_url_"]
        runner.should_receive(:process).with("_line_")
        @block = nil
        subject.should_receive(:run).with(*args) { |&b| @block = b }
        subject.run_specs(runner, "_url_")
        @block.call("_line_")
      end

    end

    context "without phantomjs" do

      it "raises a MissingDependency exception" do
        subject.should_receive(:which).and_return(nil)
        expect { subject.run_specs(:default, "_url_") }.to raise_error Teaspoon::MissingDependency
      end

    end

  end

end
