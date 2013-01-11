RSpec.configure do |config|
  config.include Aruba::Api

  config.before(:each, aruba: true) do
    @aruba_timeout_seconds = 180
    FileUtils.rm_rf(current_dir)
    @__aruba_original_paths = (ENV['PATH'] || '').split(File::PATH_SEPARATOR)
    ENV['PATH'] = ([File.expand_path('bin')] + @__aruba_original_paths).join(File::PATH_SEPARATOR)
  end

  config.after(:each, aruba: true) do
    ENV['PATH'] = @__aruba_original_paths.join(File::PATH_SEPARATOR)
    restore_env
  end
end
