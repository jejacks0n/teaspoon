require "spec_helper"

describe Teaspoon::Formatter.fetch(:rspec_html) do
  let(:suite) { double(label: "_suite&_", level: @level || 0) }
  let(:passing_spec) { double(passing?: true, failing?: false, elapsed: nil, status: "passed", label: "_passing&_") }
  let(:pending_spec) { double(passing?: false, pending?: true, failing?: false, elapsed: nil, status: "pending", label: "_pending&_", description: "_description&_") }
  let(:failing_spec) { double(passing?: false, pending?: false, failing?: true, elapsed: nil, status: "failed", label: "_failing&_", description: "_description&_", message: "_message&_", link: "_link&_", trace: "_trace&_") }

  before do
    @log = ""
    allow(STDOUT).to receive(:print) { |s| @log << s }
  end

  describe "#runner" do
    let(:result) { double(start: "_start&_", total: 42) }

    before do
      subject.instance_variable_set(:@suite_name, "not_default&")
    end

    it "starts the HTML" do
      subject.runner(result)
      expect(@log).to eq(Teaspoon::Formatter::RspecHtml::Templates::HEADER)
    end
  end

  describe "#suite" do
    it "logs a suite header" do
      subject.suite(suite)
      expect(@log).to eq(Teaspoon::Formatter::RspecHtml::Templates::SUITE_START.gsub("<%= h @o.label %>", "_suite&amp;_"))
      expect(subject.instance_variable_get(:@current_suite)).to eq(["_suite&_"])
    end

    it "finishes any ended suites" do
      subject.instance_variable_get(:@current_suite) << "Suite 1" << "Suite 2" << "Suite 3" << "Suite 4"
      @level = 2
      subject.suite(suite)
      expected_head = Teaspoon::Formatter::RspecHtml::Templates::SUITE_END * 2
      expected_tail = Teaspoon::Formatter::RspecHtml::Templates::SUITE_START.gsub("<%= h @o.label %>", "_suite&amp;_")
      expect(@log).to eq(expected_head + expected_tail)
    end
  end

  describe "#spec" do
    it "logs passing results" do
      subject.spec(passing_spec)
      expected_log = Teaspoon::Formatter::RspecHtml::Templates::SPEC.gsub("<%= h @o.status %>", "passed")
      expected_log.gsub!("<%= h @o.label %>", "_passing&amp;_")
      expected_log.gsub!("<%= h \"\#{@o.elapsed}s\" if @o.elapsed %>", "")
      expected_log.gsub!(/\<% if @o.failing\? %\>.*?\<% end %\>/m, "")
      expect(@log).to eq(expected_log)
    end

    it "logs pending results" do
      subject.spec(pending_spec)
      expected_log = Teaspoon::Formatter::RspecHtml::Templates::SPEC.gsub("<%= h @o.status %>", "pending")
      expected_log.gsub!("<%= h @o.label %>", "_pending&amp;_")
      expected_log.gsub!("<%= h \"\#{@o.elapsed}s\" if @o.elapsed %>", "")
      expected_log.gsub!(/\<% if @o.failing\? %\>.*?\<% end %\>/m, "")
      expect(@log).to eq(expected_log)
    end

    it "logs failing results" do
      subject.spec(failing_spec)
      expected_log = Teaspoon::Formatter::RspecHtml::Templates::SPEC.gsub("<%= h @o.status %>", "failed")
      expected_log.gsub!("<%= h @o.label %>", "_failing&amp;_")
      expected_log.gsub!("<%= h \"\#{@o.elapsed}s\" if @o.elapsed %>", "")
      expected_log.gsub!("<%= h @o.trace %>", "_trace&amp;_")
      expected_log.gsub!("<% if @o.failing? %>", "")
      expected_log.gsub!("<% end %>", "")
      expect(@log).to eq(expected_log)
    end
  end

  describe "#result" do
    let(:result) { double(elapsed: 3.1337, coverage: nil) }

    before do
      subject.run_count = 666
      subject.failures << failing_spec
      subject.pendings << pending_spec
    end

    it "ends the HTML" do
      subject.result(result)
      expect(@log).to eq(Teaspoon::Formatter::RspecHtml::Templates::FOOTER.gsub("<%= h @o.elapsed %>", "3.1337"))
    end

    it "finishes any remaining suites" do
      subject.instance_variable_get(:@current_suite) << "Suite 1" << "Suite 2"
      subject.result(result)
      expected_head = Teaspoon::Formatter::RspecHtml::Templates::SUITE_END * 2
      expected_tail = Teaspoon::Formatter::RspecHtml::Templates::FOOTER.gsub("<%= h @o.elapsed %>", "3.1337")
      expect(@log).to eq(expected_head + expected_tail)
    end
  end
end
