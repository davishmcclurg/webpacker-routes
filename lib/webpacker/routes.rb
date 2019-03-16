require "webpacker/routes/version"
require "webpacker/routes/railtie"

module Webpacker
  class Configuration
    def routes_path
      fetch(:routes_path) || source_path.join('routes')
    end
  end

  module Routes
    JAVASCRIPT_VARIABLE_NAME_REGEX = /\A[_$a-z][_$a-z0-9]*\z/i
    IGNORED_OPTIONS = %i[controller action]

    class << self
      def generate(app)
        File.atomic_write(Webpacker.config.routes_path.join('index.js')) do |file|
          default_url_options = js(app.default_url_options.merge(app.config.webpacker.routes.default_url_options).except(*IGNORED_OPTIONS))

          file.write(<<-JAVASCRIPT.strip_heredoc)
            import { urlFor, pathFor } from 'webpacker-routes'
            const default_url_options = #{default_url_options}
          JAVASCRIPT

          app.routes.named_routes.sort_by(&:first).each do |name, route|
            raise `Invalid route name for javascript: ${name}` unless JAVASCRIPT_VARIABLE_NAME_REGEX =~ name

            spec = js(route.path.spec.to_s)
            segment_keys = js(route.segment_keys.uniq)
            options = js(route.defaults.except(*IGNORED_OPTIONS))

            file.write(<<-JAVASCRIPT.strip_heredoc)
              const #{name}_spec = [#{spec}, #{segment_keys}, { ...default_url_options, ...#{options} }]
              export const #{name}_url = (...args) => urlFor(#{name}_spec, ...args)
              export const #{name}_path = (...args) => pathFor(#{name}_spec, ...args)
            JAVASCRIPT
          end
        end
      end

    private

      def js(obj)
        ERB::Util.json_escape(obj.to_json)
      end
    end
  end
end
