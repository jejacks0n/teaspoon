require "spec_helper"
require "tempfile"
require "fileutils"

feature "testing hooks in the browser" do
  include Rack::Test::Methods

  let(:app) { Dummy::Application }
  let(:suites) {{
    "suite1" => {block: proc{ |suite| suite.hook :before, &proc{ File.write(temp_file, "") } }},
    "suite2" => {block: proc{ |suite| suite.hook :after, &proc{ File.write(temp_file, "") } }},
    "suite3" => {block: proc{ |suite| suite.hook :with_arguments, &proc{ |args| File.write(temp_file, args["message"]) } }},
  }}

  before do
    allow(Teaspoon.configuration).to receive(:suite_configs).and_return(suites)
    FileUtils.mkdir_p('tmp')
    File.delete(temp_file) if File.exists?(temp_file)
    expect(File.exists?(temp_file)).to eql(false)
  end

  after do
    File.delete(temp_file) if File.exists?(temp_file)
  end

  describe "requesting a before hook by name (using POST)" do

    let(:temp_file) { "tmp/before_hook_test" }

    scenario "gives me the expected results" do
      post("/teaspoon/suite1/before")
      expect(File.exists?(temp_file)).to be_truthy
    end

  end

  describe "requesting an after hook by name (using GET)" do

    let(:temp_file) { "tmp/after_hook_test" }

    scenario "gives me the expected results" do
      post("/teaspoon/suite2/after")
      expect(File.exists?(temp_file)).to be_truthy
    end

  end

  describe "requesting a before hook with arguments (using POST)" do
    let(:temp_file) { "tmp/before_hook_test" }
    let(:message) { "Hello World" }
    let(:params) do
      { args: { message: message } }
    end

    scenario "gives me the expected results" do
      post("/teaspoon/suite3/with_arguments", params)
      expect(File.open(temp_file).gets.chomp).to eq(message)
    end
  end
end
