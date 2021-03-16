require "webdrivers"

def register_driver(browser, name, args, headless: false)
  case browser
  when :firefox
    options = Selenium::WebDriver::Firefox::Options.new
  when :chrome
    options = Selenium::WebDriver::Chrome::Options.new
  else
    raise "what browser?"
  end

  Capybara.register_driver(name) do |app|
    args.each { |arg| options.add_argument arg }
    options.headless! if headless
    Capybara::Selenium::Driver.new(app, browser: browser, options: options)
  end
end

driver_arguments = %w[
  disable-impl-side-painting
  window-size=1440,1080
  no-sandbox
  disable-gpu
  disable-dev-shm-usage
  verbose
]
register_driver(:chrome, :chrome, driver_arguments)
register_driver(:chrome, :chrome_headless, driver_arguments, headless: true)
register_driver(:firefox, :firefox, driver_arguments)
register_driver(:firefox, :firefox_headless, driver_arguments, headless: true)
