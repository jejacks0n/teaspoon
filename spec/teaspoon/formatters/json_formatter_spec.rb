require "spec_helper"

describe Teaspoon::Formatters::JsonFormatter do

  let(:hash) { {original_json: "_original_json_"} }
  let(:result) { double(hash) }

  describe "#runner" do

    let(:result) { double(hash.merge(total: 42)) }

    it "logs the original json" do
      subject.should_receive(:log_result).with(result)
      subject.runner(result)
    end

  end

  describe "#suite" do

    it "logs the original json" do
      subject.should_receive(:log_result).with(result)
      subject.suite(result)
    end

  end

  describe "#spec" do

    let(:result) { double(hash.merge(passing?: true)) }

    it "logs the original json" do
      subject.should_receive(:log_result).with(result)
      subject.spec(result)
    end

  end

  describe "#error" do

    it "logs the original json" do
      subject.should_receive(:log_result).with(result)
      subject.error(result)
    end

  end

  describe "#exception" do

    it "logs the original json" do
      subject.should_receive(:log_result).with(result)
      subject.exception(result)
    end

  end

  describe "#console" do

    it "logs the message as json" do
      subject.should_receive(:log_line).with(%Q{{"type":"console","log":"_message_"}})
      subject.console("_message_")
    end

  end

  describe "#result" do

    let(:result) { double(hash.merge(coverage: nil)) }

    it "logs the original json" do
      subject.should_receive(:log_str).with("_original_json_")
      subject.result(result)
    end

  end

end
