desc "Run the javascript specs"
task :teaspoon => :environment do
  require "teaspoon/console"
  fail if Teaspoon::Console.new({suite: ENV["suite"], driver_cli_options: ENV["driver_cli_options"]}).execute
end

task :teabag => :teaspoon do
  puts "Deprecation Notice: Please update your rake tasks to use 'teaspoon' instead of 'teabag'"
end
