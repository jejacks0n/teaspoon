module Teaspoon
  module Framework
    class Base
      class << self
        attr_accessor :_versions
        attr_accessor :_asset_paths
        attr_accessor :_template_paths
        attr_accessor :_install_path
        attr_accessor :_install_proc

        def inherited(base)
          base._versions = {}
          base._asset_paths = []
          base._template_paths = []
          base._install_path = "spec"
          base._install_proc = proc {}
        end

        def framework_name(name = nil)
          name.present? ? @_framework_name ||= name.to_sym : @_framework_name
        end

        def register_version(version, js_runner, options = {})
          dependencies = options[:dependencies] || []
          dev_deps = options[:dev_deps] || []

          if ENV["TEASPOON_DEVELOPMENT"] && dev_deps.any?
            dependencies = dev_deps
          end

          if dependencies.empty?
            raise Teaspoon::UnspecifiedDependencies.new(framework: @_framework_name, version: version)
          end

          dependencies.unshift(js_runner)
          @_versions[version] = dependencies
          Teaspoon.configuration.asset_manifest += dependencies
        end

        def add_asset_path(path)
          @_asset_paths << path
        end

        def add_template_path(path)
          @_template_paths << path
        end

        def install_to(path, &block)
          @_install_path = path
          @_install_proc = block if block_given?
        end

        def description
          "#{@_framework_name}[#{@_versions.keys.join(', ')}]"
        end

        def asset_paths
          @_asset_paths
        end

        def versions
          _versions.keys
        end

        def name
          framework_name
        end

        def javascripts_for(version = nil)
          _versions[version || versions.last]
        end

        def template_paths
          _template_paths
        end

        def install_path
          _install_path
        end

        def install_callback
          _install_proc
        end

        def modify_config(_config)
          # noop - Implement this in subclass to modify suite configuration
        end
      end
    end
  end
end
