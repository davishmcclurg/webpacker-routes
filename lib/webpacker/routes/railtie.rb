require 'webpacker/railtie'

module Webpacker
  module Routes
    class Engine < ::Rails::Engine
      config.webpacker.routes = ActiveSupport::OrderedOptions.new
      config.webpacker.routes.default_url_options = {}
      config.webpacker.routes.camel_case = false

      config.after_initialize do |app|
        if Rails.gem_version >= Gem::Version.new('5.0.0')
          app.reloader.to_run(:after) { Webpacker::Routes.generate(app) }
        else
          ActionDispatch::Reloader.to_prepare(:after) { Webpacker::Routes.generate(app) }
        end
        Webpacker::Routes.generate(app.tap(&:reload_routes!)) unless ENV['WEBPACKER_ROUTES_INSTALL']
      end
    end
  end
end
