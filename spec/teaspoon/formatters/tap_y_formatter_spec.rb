require "spec_helper"

describe Teaspoon::Formatters::TapYFormatter do

  let(:passing_spec) { double(passing?: true, label: "_passing_label_") }
  let(:pending_spec) { double(passing?: false, pending?: true, label: "_pending_label_", message: "_message_") }
  let(:failing_spec) { double(passing?: false, pending?: false, label: "_failing_label_", message: "_message_", link: "_link_") }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:result) { double(start: "_start_", total: 42) }

    it "logs the information" do
      subject.runner(result)
      expect(@log).to eq("---\ntype: suite\nstart: _start_\ncount: 42\nseed: 0\nrev: 4\n")
    end

  end

  describe "#suite" do

    let(:result) { double(label: "_label_", level: 1) }

    it "logs the information" do
      subject.suite(result)
      expect(@log).to eq("---\ntype: case\nlabel: _label_\nlevel: 1\n")
    end

  end

  describe "#spec" do

    it "calls passing_spec passing results" do
      subject.spec(passing_spec)
      expect(@log).to eq("---\ntype: test\nstatus: pass\nlabel: _passing_label_\nstdout: ''\n")
    end

    it "calls pending_spec on pending results" do
      subject.spec(pending_spec)
      expect(@log).to eq("---\ntype: test\nstatus: pending\nlabel: _pending_label_\nstdout: ''\nexception:\n  message: _message_\n")
    end

    it "calls failing_spec on failing results" do
      subject.spec(failing_spec)
      expect(@log).to eq("---\ntype: test\nstatus: fail\nlabel: _failing_label_\nstdout: ''\nexception:\n  message: _message_\n  backtrace:\n  - _link_#:0\n  file: unknown\n  line: unknown\n  source: unknown\n  snippet:\n    '0': _link_\n  class: Unknown\n")
    end

    it "provides the stdout" do
      subject.instance_variable_set(:@stdout, "_stdout_")
      subject.spec(passing_spec)
      expect(@log).to eq("---\ntype: test\nstatus: pass\nlabel: _passing_label_\nstdout: _stdout_\n")
    end

  end

  describe "#result" do

    let(:result) { double(elapsed: 3.1337, coverage: nil) }

    before do
      subject.run_count = 6
      subject.passes = [1, 2]
      subject.failures = [1]
      subject.errors = [1]
      subject.pendings = [1, 2]
    end

    it "logs the information" do
      subject.result(result)
      expect(@log).to eq("---\ntype: final\ntime: 3.1337\ncounts:\n  total: 6\n  pass: 2\n  fail: 1\n  error: 1\n  omit: 0\n  todo: 2\n")
    end

  end

end
