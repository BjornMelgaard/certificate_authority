if ENV['RSPEC_SELENIUM']
  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end
  Capybara.default_driver = :selenium_chrome
  Capybara.javascript_driver = :selenium_chrome
else
  Capybara.default_driver = :webkit
  Capybara.javascript_driver = :webkit
end

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
