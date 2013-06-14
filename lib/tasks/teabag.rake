desc "Run the javascript specs"
task :teabag => :environment do
  require "teabag/console"
  fail if Teabag::Console.new({suite: ENV["suite"], driver_cli_options: ENV["driver_cli_options"]}).execute
end
