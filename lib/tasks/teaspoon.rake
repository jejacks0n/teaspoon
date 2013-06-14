desc "Run the javascript specs"
task :teaspoon => :environment do
  require "teaspoon/console"
  fail if Teaspoon::Console.new({suite: ENV["suite"]}).execute
end
