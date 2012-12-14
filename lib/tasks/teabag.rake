desc "Run the javascript specs"
task :teabag => :environment do
  require "teabag/console"
  fail if Teabag::Console.new(ENV["suite"]).execute
end
