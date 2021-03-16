require "webdrivers"

def register_driver(name, chrome_options = [])
  Capybara.register_driver(name) do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    chrome_options.each do |arg|
      options.add_argument arg
    end
    #capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end

base_chrome_options = %w[
  --window-size=1440,1080
  --no-sandbox
  --disable-gpu
  --disable-dev-shm-usage
]
register_driver(:chrome, base_chrome_options)
headless_options = base_chrome_options + %w[
  --headless
]
register_driver(:chrome_headless, headless_options)
