module Teaspoon
  module Utility

    def which(cmd)
      exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]

      ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = "#{ path }/#{ cmd }#{ ext }"
          return exe if File.executable?(exe)
        end
      end

      node_module?(cmd) || nil
    end

    def node_module?(cmd)
      "./node_modules/.bin/#{cmd}" if File.executable?("./node_modules/.bin/#{cmd}")
    end
  end
end
