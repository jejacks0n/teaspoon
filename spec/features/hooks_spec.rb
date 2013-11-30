require "spec_helper"
require "tempfile"
require "fileutils"

feature "testing hooks in the browser" do
  include Rack::Test::Methods

  before do
    Teaspoon.configuration.stub(:suites).and_return "before_hooks" => proc{ |suite|
      suite.hook :before do
        File.write('tmp/before_hook_test' , '')
      end
    }
  end

  let(:temp_file) { 'tmp/before_hook_test' }

  def app
    Dummy::Application
  end

  before do
    FileUtils.mkdir 'tmp' unless File.directory?('tmp')
    File.delete(temp_file) if File.exists?(temp_file)
  end

  scenario "gives me the expected results" do
    expect(File.exists?(temp_file)).to eql(false)

    post "/teaspoon/before_hooks/hooks/before"

    expect(File.exists?(temp_file)).to eql(true)
  end
end

feature "testing after hooks in the browser" do
  include Rack::Test::Methods

  before do
    Teaspoon.configuration.stub(:suites).and_return "default" => proc{ |suite|
      suite.hook :default do
        File.write('tmp/default_hook_test', '')
      end
    }
  end

  let(:temp_file) { 'tmp/default_hook_test' }

  def app
    Dummy::Application
  end

  before do
    FileUtils.mkdir 'tmp' unless File.directory?('tmp')
    File.delete(temp_file) if File.exists?(temp_file)
  end

  scenario "gives me the expected results" do
    expect(File.exists?(temp_file)).to eql(false)

    post "/teaspoon/default/hooks"

    expect(File.exists?(temp_file)).to eql(true)
  end
end
