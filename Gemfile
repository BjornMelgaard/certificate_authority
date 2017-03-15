source 'https://rubygems.org'
ruby '~> 2.4.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'haml-rails'

gem 'bulma-rails', '~> 0.3.2'
gem 'certificate_authority'

gem 'dotenv-rails'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'awesome_pry'
  gem 'guard-livereload', require: false
  gem 'guard-rspec', require: false
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'sqlite3'

  gem 'factory_girl_rails'
  gem 'ffaker'

  # RSpec
  gem 'rspec-rails'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
  gem 'capybara-screenshot'
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'fuubar', require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
