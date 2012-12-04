desc "Run the javascript specs"
task :teabag => :environment do
  require "teabag/console"
  code = Teabag::Console.new(ENV["suite"] || :default).execute
  fail if code != 0
end
