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

        parent_spec_var = var_name.call('parent_spec')
        default_url_options_var = var_name.call('default_url_options')

        route_sets = [[app.routes, nil, Webpacker.config.routes_path]]
        visited_directories = []

        while (route_set, parent, directory = route_sets.shift)
          directory.mkpath
          visited_directories << directory
          js_file = directory.join('index.js')

          catch(:identical) do
            File.atomic_write(js_file) do |temp_file|
              parent_var_definition = if parent
                "import { #{parent} as #{parent_spec_var} } from '../'"
              else
                "const #{parent_spec_var} = null"
              end

              temp_file.write(<<-JAVASCRIPT.strip_heredoc)
                import { urlFor, pathFor } from 'webpacker-routes'
                #{parent_var_definition}
                const #{default_url_options_var} = #{js(default_url_options)}
              JAVASCRIPT

              route_set.named_routes.sort_by(&:first).each do |name, route|
                raise `Invalid route name for javascript: ${name}` unless JAVASCRIPT_VARIABLE_NAME_REGEX =~ name

                spec = route.path.spec.to_s
                segment_keys = route.segment_keys.uniq
                options = route.defaults.except(*IGNORED_OPTIONS)

                spec_var = var_name.call("#{name}_spec")
                url_var = var_name.call("#{name}_url")
                path_var = var_name.call("#{name}_path")

                temp_file.write(<<-JAVASCRIPT.strip_heredoc)
                  export const #{spec_var} = [#{js(spec)}, #{js(segment_keys)}, { ...#{default_url_options_var}, ...#{js(options)} }, #{parent_spec_var}]
                  export const #{url_var} = (...args) => urlFor(#{spec_var}, ...args)
                  export const #{path_var} = (...args) => pathFor(#{spec_var}, ...args)
                JAVASCRIPT

                if engine?(route)
                  engine = rack_app(route)
                  engine_name = engine.railtie_name

                  raise `Invalid engine name for javascript: ${engine_name}` unless JAVASCRIPT_VARIABLE_NAME_REGEX =~ engine_name

                  engine_name_var = var_name.call(engine_name)

                  route_sets << [engine.routes, spec_var, directory.join(engine_name_var)]
                end
              end

              temp_file.close
              if identical?(js_file.to_s, temp_file.path)
                temp_file.unlink
                throw :identical
              end
            end
          end
        end

        extra_directories = Webpacker.config.routes_path.glob('**/*').select(&:directory?) - visited_directories
        extra_directories.sort_by { |directory| directory.to_s.size }.reverse_each(&:rmtree)
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

      def rack_app(route)
        route.app.app
      end

      def engine?(route)
        app = rack_app(route)
        app.is_a?(Class) && app < Rails::Engine
      end
    end
  end
end
