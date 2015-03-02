module Teaspoon
  class Framework
    class << self
      attr_accessor :_versions
      attr_accessor :_asset_paths
      attr_accessor :_template_paths
      attr_accessor :_install_path
      attr_accessor :_install_proc
    end

    def self.inherited(base)
      base._versions = {}
      base._asset_paths = []
      base._template_paths = []
      base._install_path = "spec"
      base._install_proc = proc {}
    end

    def self.framework_name(name = nil)
      name.present? ? @_framework_name ||= name.to_sym : @_framework_name
    end

    def self.register_version(version, *dependencies)
      @_versions[version] = dependencies
    end

    def self.add_asset_path(path)
      @_asset_paths << path
    end

    def self.add_template_path(path)
      @_template_paths << path
    end

    def self.install_to(path, &block)
      @_install_path = path
      @_install_proc = block if block_given?
    end

    def self.description
      "#{@_framework_name}[#{@_versions.keys.join(', ')}]"
    end

    def self.asset_paths
      @_asset_paths
    end

    def initialize(_config)
    end

    def name
      self.class.framework_name
    end

    def versions
      self.class._versions.keys
    end

    def javascripts_for(version = nil)
      self.class._versions[version || versions.last]
    end

    def template_paths
      self.class._template_paths
    end

    def install_path
      self.class._install_path
    end

    def install_callback
      self.class._install_proc
    end
  end
end
