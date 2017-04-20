require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require "action_cable/engine"
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv::Railtie.load unless Rails.env.production?

module CertificateAuthority
  class Application < Rails::Application
    if Rails.env.production?
      config.eager_load_paths << Rails.root.join('lib')
    else
      config.autoload_paths << Rails.root.join('lib')
    end

    require Rails.root.join('app', 'middleware', 'ocsp_middleware')
    config.middleware.use OcspMiddleware

    # on heroku filesystem is ephemeral
    # so `rake certificate_authority::populate_ca` is not working
    config.after_initialize do
      PopulateCA.call if Rails.env.production?
    end
  end
end
