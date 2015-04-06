require "spec_helper"

describe Teaspoon::Framework do
  subject { Class.new(Teaspoon::Framework) }

  describe "registering versions" do
    before do
      subject.framework_name "framework"
      subject.register_version "1.0.0", "framework/1.0.0", "teaspoon-framework"
      subject.register_version "2.0.0", "framework/2.0.0", "teaspoon-framework"
    end

    it "tracks the registered versions" do
      versions = subject.new("_suite_config_").versions
      expect(versions).to eq(["1.0.0", "2.0.0"])
    end

    it "can describe itself" do
      expect(subject.description).to eq("framework[1.0.0, 2.0.0]")

      name = subject.new("_suite_config_").name
      expect(name).to eq(:framework)
    end

    it "can generate a list of dependencies for a given version" do
      dependencies = subject.new("_suite_config_").javascripts_for("1.0.0")
      expect(dependencies).to eq(["framework/1.0.0", "teaspoon-framework"])
    end

    it "can generate a list of dependencies for the preferred version" do
      subject.register_version "2.0.0", "framework/2.0.0", "teaspoon-framework"

      dependencies = subject.new("_suite_config_").javascripts_for
      expect(dependencies).to eq(["framework/2.0.0", "teaspoon-framework"])
    end
  end

  describe "adding asset paths" do
    before do
      subject.add_asset_path "/foo/bar"
    end

    it "tracks specified template paths" do
      subject.add_asset_path File.expand_path("../assets", __FILE__)

      asset_paths = subject.asset_paths
      expect(asset_paths[0]).to eq("/foo/bar")
      expect(asset_paths[1]).to include("/teaspoon/spec/teaspoon/assets")
    end
  end

  describe "adding custom install templates" do
    before do
      subject.add_template_path "/foo/bar"
    end

    it "tracks specified template paths" do
      subject.add_template_path File.expand_path("../templates", __FILE__)

      template_paths = subject.new("_suite_config_").template_paths
      expect(template_paths[0]).to eq("/foo/bar")
      expect(template_paths[1]).to include("/teaspoon/spec/teaspoon/templates")
    end
  end

  describe "customizing the installation further" do
    it "has a default of 'spec'" do
      install_path = subject.new("_suite_config_").install_path
      expect(install_path).to eq("spec")
    end

    it "allows specifying an install path" do
      subject.install_to "custom"

      install_path = subject.new("_suite_config_").install_path
      expect(install_path).to eq("custom")
    end

    it "allows providing a block that will be called within the install generator" do
      callback = proc {}
      subject.install_to("path/to/install", &callback)

      expect(subject.new("_suite_config_").install_callback).to eq(callback)
    end
  end
end
