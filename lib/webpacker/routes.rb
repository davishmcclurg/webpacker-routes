require "webpacker/routes/version"
require "webpacker/routes/railtie"

module Webpacker
  class Configuration
    def routes_path
      source_path.join('routes')
    end
  end

  module Routes
    JAVASCRIPT_VARIABLE_NAME_REGEX = /\A[_$a-z][_$a-z0-9]*\z/i

    def self.generate(route_set)
      File.atomic_write(Webpacker.config.routes_path.join('index.js')) do |file|
        file.write(<<-JAVASCRIPT.strip_heredoc)
          import { urlFor, pathFor } from 'webpacker-routes'
        JAVASCRIPT

        route_set.named_routes.sort_by(&:first).each do |name, route|
          raise `Invalid route name for javascript: ${name}` unless JAVASCRIPT_VARIABLE_NAME_REGEX =~ name

          spec = route.path.spec.to_s.to_json
          segment_keys = route.segment_keys.uniq.to_json
          defaults = route.defaults.except(:controller, :action).to_json

          file.write(<<-JAVASCRIPT.strip_heredoc)
            const #{name}_spec = [#{spec}, #{segment_keys}, #{defaults}]
            export const #{name}_url = (...args) => urlFor(#{name}_spec, ...args)
            export const #{name}_path = (...args) => pathFor(#{name}_spec, ...args)
          JAVASCRIPT
        end
      end
    end
  end
end
