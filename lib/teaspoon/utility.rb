module Teaspoon
  module Utility

    # Cross-platform way of finding an executable in the $PATH.
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    #
    # @example
    #   which('ruby') #=> /usr/bin/ruby
    #
    # @param cmd [String] the executable to find
    # @return [String, nil] the path to the executable
    #
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = "#{ path }/#{ cmd }#{ ext }"
          return exe if File.executable?(exe)
        end
      end

      nil
    end

    def istanbul()
      # find istanbul in path or local npm install
      which("istanbul") || (File.executable?("./node_modules/.bin/istanbul") ? "./node_modules/.bin/istanbul" : nil)
    end
  end
end
