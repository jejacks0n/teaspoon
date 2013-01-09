desc "Run the javascript specs"
task :teabag => :environment do
  require "teabag/console"
  fail if Teabag::Console.new({suite: ENV["suite"]}).execute
end
