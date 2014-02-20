module Teaspoon
  class Exporter
    include Teaspoon::Utility

    def initialize(suite, url, output_path)
      @suite = suite
      @url = url
      @output_path = File.join(File.expand_path(output_path || "export"), @suite.to_s)
    end

    def export
      Dir.mktmpdir do |temp_path|
        Dir.chdir(temp_path) do
          %x{#{executable} --convert-links --adjust-extension --page-requisites --span-hosts #{@url.shellescape} 2>&1}
          raise Teaspoon::ExporterException, "Unable to export #{@suite} suite." unless $?.exitstatus == 0
          create_export(File.join(temp_path, @url.match(/^http:\/\/([^\/]+).*/)[1]))
        end
      end
    end

    private

    def executable
      return @executable if @executable
      @executable = which("wget")
      return @executable unless @executable.blank?
      raise Teaspoon::MissingDependency, "Could not find wget for exporting."
    end

    def create_export(path)
      Dir.chdir(path) do
        update_relative_paths
        cleanup_output
        move_output
      end
    end

    def update_relative_paths
      html = File.read(".#{Teaspoon.configuration.mount_at}/#{@suite}.html")
      File.write("index.html", html.gsub!('"../', '"'))
    end

    def cleanup_output
      FileUtils.rm_r(Dir["{.#{Teaspoon.configuration.mount_at},robots.txt.html}"])
    end

    def move_output
      FileUtils.mkdir_p(@output_path)
      FileUtils.mv(Dir["*"], @output_path, force: true)
    end
  end
end
