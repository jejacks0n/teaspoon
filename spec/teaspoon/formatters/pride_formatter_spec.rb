require "spec_helper"

describe Teaspoon::Formatters::PrideFormatter do

  let(:passing_spec) { double(passing?: true) }
  let(:pending_spec) { double(passing?: false, pending?: true) }
  let(:failing_spec) { double(passing?: false, pending?: false) }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#spec" do

    it "logs a colorful . on passing results" do
      subject.spec(passing_spec)
      subject.spec(passing_spec)
      subject.spec(passing_spec)
      subject.spec(passing_spec)
      subject.spec(passing_spec)
      expect(@log).to eq("\e[38;5;154m.\e[0m\e[38;5;154m.\e[0m\e[38;5;148m.\e[0m\e[38;5;184m.\e[0m\e[38;5;184m.\e[0m")
    end

    it "logs a yellow * on pending results" do
      subject.spec(pending_spec)
      expect(@log).to eq("\e[33m*\e[0m")
    end

    it "logs a red F on failing results" do
      subject.spec(failing_spec)
      expect(@log).to eq("\e[31mF\e[0m")
    end

  end

end
