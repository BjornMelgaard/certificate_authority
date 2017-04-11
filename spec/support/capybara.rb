require 'capybara/poltergeist'
require_relative 'helpers/downloads'

if ENV['RSPEC_SELENIUM']
  Capybara.register_driver :selenium_chrome do |app|
    prefs = {
      download: {
        prompt_for_download: false,
        default_directory: DownloadHelpers::PATH
      },
      profile: {
        default_content_settings: {
          popups: 0,
          'multiple-automatic-downloads': 1
        }
      }
    }

    Capybara::Selenium::Driver.new(app, browser: :chrome, prefs: prefs)
  end
  Capybara.default_driver = :selenium_chrome
  Capybara.javascript_driver = :selenium_chrome
else
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
end
