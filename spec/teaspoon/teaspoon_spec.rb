describe Teaspoon do
  subject { described_class }

  it "has a configuration property" do
    expect(subject.configuration).to be(Teaspoon::Configuration)
  end

  describe ".configure" do
    it "yields configuration" do
      config = nil
      subject.configure { |c| config = c }
      expect(config).to be(Teaspoon::Configuration)
    end

    it "sets configured to true" do
      subject.configured = false
      subject.configure {}
      expect(subject.configured).to be_truthy
    end

    it "overrides configuration from ENV" do
      expect(subject.configuration).to receive(:override_from_env).with(ENV)
      subject.configure {}
    end
  end

  describe ".setup" do
    it "calls configure" do
      block = proc {}
      expect(subject).to receive(:configure).with(no_args) { |&arg| expect(arg).to eq(block) }
      subject.setup(&block)
    end
  end
end
