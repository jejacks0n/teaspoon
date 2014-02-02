require "spec_helper"

describe Teaspoon::Formatters::TeamcityFormatter do

  let(:passing_spec) { double(passing?: true, description: "_passing_[desc]\rip|'o\n_") }
  let(:pending_spec) { double(passing?: false, pending?: true, description: "_pending_[desc]_") }
  let(:failing_spec) { double(passing?: false, pending?: false, description: "_failing_[desc]_", message: "_failure_[mess]age_") }

  before do
    @log = ""
    STDOUT.stub(:print) { |s| @log << s }
  end

  describe "#runner" do

    let(:result) { double(total: 42, start: "_start_") }

    it "starts the suite" do
      Time.should_receive(:now).and_return(double(to_json: "_json_time_"))
      subject.runner(result)
      expect(@log).to include("##teamcity[enteredTheMatrix timestamp='_json_time_']\n")
      expect(@log).to include("##teamcity[testCount count='42' timestamp='_start_']\n")
    end

  end

  describe "#spec" do

    it "logs a passing testcase on passing results" do
      subject.spec(passing_spec)
      expect(@log).to include(%Q{##teamcity[testStarted name='_passing_|[desc|]|rip|||'o|n_' captureStandardOutput='true']\n})
      expect(@log).to include(%Q{##teamcity[testFinished name='_passing_|[desc|]|rip|||'o|n_']\n})
    end

    it "logs a skipped testcase on pending results" do
      subject.spec(pending_spec)
      expect(@log).to include(%Q{##teamcity[testIgnored name='_pending_|[desc|]_' captureStandardOutput='true']\n})
      expect(@log).to include(%Q{##teamcity[testFinished name='_pending_|[desc|]_']\n})
    end

    it "logs a failing testcase with the message on failing results" do
      subject.spec(failing_spec)
      expect(@log).to include(%Q{##teamcity[testStarted name='_failing_|[desc|]_' captureStandardOutput='true']\n})
      expect(@log).to include(%Q{##teamcity[testFailed name='_failing_|[desc|]_' message='_failure_|[mess|]age_']\n})
      expect(@log).to include(%Q{##teamcity[testFinished name='_failing_|[desc|]_']\n})
    end

    it "captures stdout and puts it in the right place" do
      subject.instance_variable_set(:@stdout, "_stdout_\n")
      subject.spec(pending_spec)
      expect(@log).to include(%Q{##teamcity[testIgnored name='_pending_|[desc|]_' captureStandardOutput='true']\n})
      expect(@log).to include(%Q{_stdout_\n})
      expect(@log).to include(%Q{##teamcity[testFinished name='_pending_|[desc|]_']\n})
    end

  end

  describe "#error" do

    let(:result) { double(message: "_error_message_", trace: [{"file" => "myfile.js", "line" => "420"}, {"file" => "myfile.js", "line" => "666"}]) }

    it "logs the error" do
      subject.error(result)
      expect(@log).to include(%Q{##teamcity[message text='_error_message_' errorDetails='myfile.js:420|nmyfile.js:666' status='ERROR']\n})
    end

  end

  describe "#result" do

    let(:result) { double(elapsed: 3.1337, coverage: nil) }

    before do
      subject.instance_variable_set(:@last_suite, double(label: "_last_suite_label_"))

      subject.run_count = 6
      subject.passes = [1, 2]
      subject.failures = [1]
      subject.errors = [1]
      subject.pendings = [1, 2]
    end

    it "ends the suite" do
      expect { subject.result(result) }.to raise_error Teaspoon::Failure
      expect(@log).to include(%Q{##teamcity[testSuiteFinished name='_last_suite_label_']\n\n})
      expect(@log).to include(%Q{Finished in 3.1337 seconds\n})
      expect(@log).to include(%Q{6 examples, 1 failure, 2 pending\n\n})
    end

  end

end
