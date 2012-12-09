desc "Run the javascript specs"
task :teabag => :environment do
  require "teabag/console"
  code = Teabag::Console.new(ENV["suite"]).execute
  fail if code != 0
end
