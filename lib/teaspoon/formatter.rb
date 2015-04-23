require "teaspoon/registry"
require "teaspoon/registry/has_default"

module Teaspoon
  module Formatter
    extend Teaspoon::Registry
    extend Teaspoon::Registry::HasDefault

    not_found_in_registry Teaspoon::UnknownFormatter
  end
end

# CONTRIBUTORS:
# If you add a formatter you should do the following before it will be considered for merging.
# - add it to this list so it can be autoloaded
# - write specs for it
# - add it to the readme so it's documented

Teaspoon::Formatter.register(:dot, "Teaspoon::Formatter::Dot", "teaspoon/formatter/dot", description: "dots", default: true)
Teaspoon::Formatter.register(:clean, "Teaspoon::Formatter::Clean", "teaspoon/formatter/clean", description: "like dots but doesn't log re-run commands")
Teaspoon::Formatter.register(:documentation, "Teaspoon::Formatter::Documentation", "teaspoon/formatter/documentation", description: "descriptive documentation")
Teaspoon::Formatter.register(:json, "Teaspoon::Formatter::Json", "teaspoon/formatter/json", description: "json formatter (raw teaspoon)")
Teaspoon::Formatter.register(:junit, "Teaspoon::Formatter::Junit", "teaspoon/formatter/junit", description: "junit compatible formatter")
Teaspoon::Formatter.register(:pride, "Teaspoon::Formatter::Pride", "teaspoon/formatter/pride", description: "yay rainbows!")
Teaspoon::Formatter.register(:rspec_html, "Teaspoon::Formatter::RspecHtml", "teaspoon/formatter/rspec_html", description: "RSpec inspired HTML format")
Teaspoon::Formatter.register(:snowday, "Teaspoon::Formatter::Snowday", "teaspoon/formatter/snowday", description: "makes you feel all warm inside")
Teaspoon::Formatter.register(:swayze_or_oprah, "Teaspoon::Formatter::SwayzeOrOprah", "teaspoon/formatter/swayze_or_oprah", description: "quote from either Patrick Swayze or Oprah Winfrey")
Teaspoon::Formatter.register(:tap, "Teaspoon::Formatter::Tap", "teaspoon/formatter/tap", description: "test anything protocol formatter")
Teaspoon::Formatter.register(:tap_y, "Teaspoon::Formatter::TapY", "teaspoon/formatter/tap_y", description: "tap_yaml, format used by tapout")
Teaspoon::Formatter.register(:teamcity, "Teaspoon::Formatter::Teamcity", "teaspoon/formatter/teamcity", description: "teamcity compatible formatter")
