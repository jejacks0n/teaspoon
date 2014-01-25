require 'fileutils'
require 'pathname'

module Teaspoon
  class Export
    attr_accessor :output_path

    def initialize(options)
      @suite = options.fetch(:suite).to_s
      @url = options.fetch(:url).to_s
      @output_path = File.expand_path(options[:output_path] || 'teaspoon-export')
    end

    def execute
      ensure_wget_installed
      create_suite_output_directory
      Dir.chdir(suite_output_path) do
        download_suite
        rename_html_as_index
        update_relative_paths
        remove_hostname_dir
        truncate_query_from_filenames
        truncate_query_from_links
      end
    end

    ExportFailure = Class.new(RuntimeError)

    def self.run_silently(*args)
      out, err = $stdout.clone, $stderr.clone
      [$stdout, $stderr].each { |file| file.reopen('/dev/null') }
      success = system(*args)
      $stdout.reopen out
      $stderr.reopen err

      success
    end

    private

    def ensure_wget_installed
      success = self.class.run_silently 'wget', '--help'
      raise ExportFailure, "wget must be installed to export" unless success
    end

    def suite_output_path
      File.join(@output_path, @suite)
    end

    def create_suite_output_directory
      FileUtils.mkdir_p(suite_output_path)
    end

    def download_suite
      self.class.run_silently('wget', '-kEpH', @url)
    end

    def rename_html_as_index
      suite_html_output = Dir.glob(File.join('**', "#{@suite}.html")).first
      raise ExportFailure, 'wget did not download any html document' if suite_html_output.nil?
      FileUtils.move(suite_html_output, 'index.html')
    end

    def update_relative_paths
      # Assumption: the html file moved up several directories, and no asset was in those directories
      html = File.read('index.html')
      html.gsub!('../', '')
      File.write('index.html', html)
    end

    def remove_hostname_dir
      FileUtils.mv Dir.glob(File.join(suite_output_path, '*/*')), suite_output_path
    end

    def truncate_query_from_filenames
      files_with_query = Dir.glob('**/*\?*')
      files_with_query.each do |file|
        File.rename file, file.sub(/\?.*/, '')
      end
    end

    def truncate_query_from_links
      html = File.read('index.html')
      html.gsub!(/%3F[^'"]*/, '')
      File.write('index.html', html)
    end
  end
end
