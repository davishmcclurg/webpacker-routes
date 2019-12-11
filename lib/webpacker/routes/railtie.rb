require 'webpacker/railtie'

module Webpacker
  module Routes
    class Engine < ::Rails::Engine
      config.webpacker.routes = ActiveSupport::OrderedOptions.new
      config.webpacker.routes.default_url_options = {}
      config.webpacker.routes.camel_case = false

      initializer 'webpacker.routes', :after => :set_routes_reloader_hook do |app|
        generate = -> { Webpacker::Routes.generate(app) }
        if Rails::VERSION::MAJOR >= 5
          app.reloader.to_run(&generate)
        else
          ActionDispatch::Reloader.to_prepare(&generate)
        end
        generate.call unless ENV['WEBPACKER_ROUTES_INSTALL'] == 'true'
      end
    end
  end
end
