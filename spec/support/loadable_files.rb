module LoadableFiles
  FileDetails = Struct.new(:driver_file, :load_path)

  def create_loadable_file(filename, contents)
    driver_file_path = File.expand_path(filename, Dir::mktmpdir())
    driver_file = File.open(driver_file_path, "w") do |file|
      file.write(contents)
      file
    end

    @load_path = File.dirname(driver_file.path)
    $:.unshift @load_path

    FileDetails.new(driver_file, @load_path)
  end

  def cleanup_loadable_file(file)
    $:.delete_if { |dir| dir == file.load_path }
    File.delete file.driver_file.path
  end
end