namespace :teaspoon do
  desc "Print teaspoon and framework information"
  task info: :environment do
    STDOUT.print("Teaspoon: #{Teaspoon::VERSION}\n\n")

    STDOUT.print("Frameworks:\n")

    Teaspoon::Framework.available.each do |framework, _|
      STDOUT.print("  #{framework}\n")

      versions = Teaspoon::Framework.fetch(framework).versions
      versions.each { |version| STDOUT.print("    #{version}\n") }

      STDOUT.print("\n")
    end
  end
end