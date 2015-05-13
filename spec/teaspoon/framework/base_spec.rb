require "spec_helper"

describe Teaspoon::Framework::Base do
  subject do
    Class.new(Teaspoon::Framework::Base) do
      def self.modify_config(config)
        config.matcher = "new_matcher.js"
      end
    end
  end

  describe "registering versions" do
    before do
      subject.framework_name "framework"
      subject.register_version "1.0.0", "framework/1.0.0", dependencies: ["teaspoon-framework"]
      subject.register_version "2.0.0", "framework/2.0.0", dependencies: ["teaspoon-framework"]
    end

    it "tracks the registered versions" do
      expect(subject.versions).to eq(["1.0.0", "2.0.0"])
    end

    it "can describe itself" do
      expect(subject.description).to eq("framework[1.0.0, 2.0.0]")
      expect(subject.name).to eq(:framework)
    end

    it "can generate a list of dependencies for a given version" do
      expect(subject.javascripts_for("1.0.0")).to eq(["framework/1.0.0", "teaspoon-framework"])
    end

    it "can generate a list of dependencies for the preferred version" do
      subject.register_version "2.0.0", "framework/2.0.0", dependencies: ["teaspoon-framework"]

      expect(subject.javascripts_for).to eq(["framework/2.0.0", "teaspoon-framework"])
    end

    it "supports development dependencies" do
      subject.register_version "2.0.0", "framework/2.0.0", dev_deps: ["teaspoon-framework"]

      expect(subject.javascripts_for).to eq(["framework/2.0.0", "teaspoon-framework"])
    end

    context "when not development mode" do
      before do
        ENV.delete("TEASPOON_DEVELOPMENT")
      end

      after do
        ENV["TEASPOON_DEVELOPMENT"] = "true"
      end

      it "uses non development dependencies" do
        subject.register_version "2.0.0", "framework/2.0.0",
                                 dependencies: ["teaspoon-framework"],
                                 dev_deps: ["teaspoon/framework"]

        expect(subject.javascripts_for).to eq(["framework/2.0.0", "teaspoon-framework"])
      end

      it "errors with no standard dependencies" do
        expect do
          subject.register_version "2.0.0", "framework/2.0.0", dev_deps: ["teaspoon-framework"]
        end.to raise_error(Teaspoon::UnspecifiedDependencies)
      end
    end
  end

  describe "adding asset paths" do
    before do
      subject.add_asset_path "/foo/bar"
    end

    it "tracks specified template paths" do
      assets = File.expand_path("../../assets", __FILE__)
      subject.add_asset_path assets

      asset_paths = subject.asset_paths
      expect(asset_paths[0]).to eq("/foo/bar")
      expect(asset_paths[1]).to include(assets)
    end
  end

  describe "adding custom install templates" do
    before do
      subject.add_template_path "/foo/bar"
    end

    it "tracks specified template paths" do
      templates = File.expand_path("../../templates", __FILE__)
      subject.add_template_path templates

      template_paths = subject.template_paths
      expect(template_paths[0]).to eq("/foo/bar")
      expect(template_paths[1]).to include(templates)
    end
  end

  describe "customizing the installation further" do
    it "has a default of 'spec'" do
      install_path = subject.install_path
      expect(install_path).to eq("spec")
    end

    it "allows specifying an install path" do
      subject.install_to "custom"

      install_path = subject.install_path
      expect(install_path).to eq("custom")
    end

    it "allows providing a block that will be called within the install generator" do
      callback = proc {}
      subject.install_to("path/to/install", &callback)

      expect(subject.install_callback).to eq(callback)
    end

    it "allows a framework to modify the suite configuration" do
      config = Teaspoon::Configuration::Suite.new

      subject.modify_config(config)

      expect(config.matcher).to eq("new_matcher.js")
    end
  end
end
