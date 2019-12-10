require 'webpacker/railtie'

module Webpacker
  module Routes
    class Engine < ::Rails::Engine
      config.webpacker.routes = ActiveSupport::OrderedOptions.new
      config.webpacker.routes.default_url_options = {}
      config.webpacker.routes.camel_case = false

      config.after_initialize do |app|
        generate = ActiveSupport::FileUpdateChecker.new(app.routes_reloader.paths) {
          Webpacker::Routes.generate(app.tap(&:reload_routes!))
        }
        if Rails::VERSION::MAJOR >= 5
          app.reloader.to_run { generate.execute_if_updated }
        else
          ActionDispatch::Reloader.to_prepare { generate.execute_if_updated }
        end
        generate.execute unless ENV['WEBPACKER_ROUTES_INSTALL'] == 'true'
      end
    end
  end
end
