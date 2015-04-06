module Teaspoon
  def self.abort(message = nil, code = 1)
    STDOUT.print("#{message}\n") if message
    exit(code)
  end

  module Utility
    # Cross-platform way of finding an executable in the $PATH.
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def which(cmd)
      exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]

      ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = "#{path}/#{cmd}#{ext}"
          return exe if File.file?(exe) && File.executable?(exe)
        end
      end

      nil
    end
  end
end
