desc "Run the javascript specs"
task teaspoon: :environment do
  require "teaspoon/console"

  options = {
    files: ENV["files"].nil? ? [] : ENV["files"].split(","),
    suite: ENV["suite"],
    coverage: ENV["coverage"],
    driver_options: ENV["driver_options"],
  }

  options.delete_if { |k, v| v.nil? }

  abort("rake teaspoon failed") if Teaspoon::Console.new(options).failures?
end
