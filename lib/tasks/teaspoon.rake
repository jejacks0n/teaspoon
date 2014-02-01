desc "Run the javascript specs"
task :teaspoon => :environment do |t, args|
  require "teaspoon/console"

  options = {
    files: ENV["files"].nil? ? [] : ENV["files"].split(","),
    suite: ENV["suite"],
    coverage: ENV["coverage"],
    driver_options: ENV["driver_options"],
  }

  results = Teaspoon::Console.new(options).execute
  fail if results
end
