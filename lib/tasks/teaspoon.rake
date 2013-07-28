desc "Run the javascript specs"
task :teaspoon => :environment do |t, args|
  require "teaspoon/console"
  files = ENV['files'].split(',')
  fail if Teaspoon::Console.new({suite: ENV["suite"], driver_cli_options: ENV["driver_cli_options"]}, files ).execute
end

task :teabag => :teaspoon do
  puts "Deprecation Notice: Please update your rake tasks to use 'teaspoon' instead of 'teabag'"
end
