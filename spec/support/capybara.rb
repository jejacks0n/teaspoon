require "webdrivers"

def register_driver(name, args = [], opts = {})
  Capybara.register_driver(name) do |app|
    options = { args: args + ["window-size=1440,1080"] }
    options[:binary] = ENV.fetch("GOOGLE_CHROME_SHIM", nil)
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: options.compact)
    Capybara::Selenium::Driver.new(app, { browser: :chrome, desired_capabilities: capabilities }.merge(opts))
  end
end

register_driver(:chrome)
register_driver(:chrome_headless, %w[headless disable-gpu no-sandbox disable-dev-shm-usage])
