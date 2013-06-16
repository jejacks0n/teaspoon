desc "Run the javascript specs"
task :teaspoon => :environment do
  require "teaspoon/console"
  fail if Teaspoon::Console.new({suite: ENV["suite"], driver_cli_options: ENV["driver_cli_options"]}).execute
end
