desc "Run the javascript specs"
task :teaspoon => :environment do |t, args|
  require "teaspoon/console"
  files = ENV['files'].nil? ? [] : ENV['files'].split(',')
  fail if Teaspoon::Console.new({suite: ENV["suite"], driver_cli_options: ENV["driver_cli_options"]}, files ).execute
end
