# encoding: utf-8

require "spec_helper"

describe Teaspoon::Formatters::SnowdayFormatter do

  let(:passing_spec) { double(passing?: true) }
  let(:pending_spec) { double(passing?: false, pending?: true) }
  let(:failing_spec) { double(passing?: false, pending?: false) }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#spec" do

    it "logs a snowy snowman on passing results" do
      subject.spec(passing_spec)
      expect(@log).to eq("\e[36m☃\e[0m")
    end

    it "logs a yellow sadface on pending results" do
      subject.spec(pending_spec)
      expect(@log).to eq("\e[33m☹\e[0m")
    end

    it "logs a red skull and crossbones on failing results" do
      subject.spec(failing_spec)
      expect(@log).to eq("\e[31m☠\e[0m")
    end

  end

end
