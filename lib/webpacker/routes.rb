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
        config = app.config.webpacker.routes
        var_name = -> (name) { config.camel_case ? name.camelize(:lower) : name }

        default_url_options = app.default_url_options.dup
        default_url_options[:relative_url_root] = app.config.relative_url_root if app.config.relative_url_root
        default_url_options.merge!(config.default_url_options)
        default_url_options.except!(*IGNORED_OPTIONS)

        default_url_options_var = var_name.call('default_url_options')

        js_file = Webpacker.config.routes_path.join('index.js')

        catch(:identical) do
          File.atomic_write(js_file) do |temp_file|
            temp_file.write(<<-JAVASCRIPT.strip_heredoc)
              import { urlFor, pathFor } from 'webpacker-routes'
              const #{default_url_options_var} = #{js(default_url_options)}
            JAVASCRIPT

            app.routes.named_routes.sort_by(&:first).each do |name, route|
              raise `Invalid route name for javascript: ${name}` unless JAVASCRIPT_VARIABLE_NAME_REGEX =~ name

              spec = route.path.spec.to_s
              segment_keys = route.segment_keys.uniq
              options = route.defaults.except(*IGNORED_OPTIONS)

              spec_var = var_name.call("#{name}_spec")
              url_var = var_name.call("#{name}_url")
              path_var = var_name.call("#{name}_path")

              temp_file.write(<<-JAVASCRIPT.strip_heredoc)
                const #{spec_var} = [#{js(spec)}, #{js(segment_keys)}, { ...#{default_url_options_var}, ...#{js(options)} }]
                export const #{url_var} = (...args) => urlFor(#{spec_var}, ...args)
                export const #{path_var} = (...args) => pathFor(#{spec_var}, ...args)
              JAVASCRIPT
            end

            temp_file.close
            if identical?(js_file.to_s, temp_file.path)
              temp_file.unlink
              throw :identical
            end
          end
        end
      end

    private

      def js(obj)
        ERB::Util.json_escape(obj.to_json)
      end

      def identical?(path1, path2)
        FileUtils.compare_file(path1, path2)
      rescue Errno::ENOENT
        false
      end
    end
  end
end
