require "aruba/api"

module Teaspoon
  module Helpers
    def all_output
      all_commands.map { |c| c.output }.join("\n")
    end
  end
end
