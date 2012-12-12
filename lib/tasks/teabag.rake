desc "Run the javascript specs"
task :teabag => ['teabag:set_env', :environment] do
  require "teabag/console"
  failed = Teabag::Console.new(ENV["suite"]).execute
  fail if failed
end

task "teabag:set_env" do
  ENV["RAILS_ENV"] = "test" # todo: not working like expected
end
