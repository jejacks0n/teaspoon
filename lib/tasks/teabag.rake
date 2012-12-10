desc "Run the javascript specs"
task :teabag => :environment do
  require "teabag/console"
  failed = Teabag::Console.new(ENV["suite"]).execute
  fail if failed
end
