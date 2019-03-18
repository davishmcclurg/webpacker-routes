# Webpacker::Routes
Webpacker Routes allows you to import Rails routes in your Webpacker javascript.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'webpacker-routes'
```

And then execute:
```bash
$ bundle
$ bundle exec rails webpacker:install:routes
```

## Usage
Import individual routes from any Webpacker-compiled file:

```javascript
import { root_path, root_url } from 'routes'

root_path()
// /

root_path({ foo: 'bar' })
// /?foo=bar

root_url({ host: 'https://example.com' })
// https://example.com/

root_url({ host: 'https://example.com', bar: 'baz' })
// https://example.com/?bar=baz

root_url({
  anchor: 'abc',
  host: 'example.com',
  params: {
    foo: 'bar'
  },
  port: 3000,
  protocol: 'https',
  relative_url_root: '/rel',
  trailing_slash: true,
  bar: 'baz'
})
// https://example.com:3000/rel/?bar=baz&foo=bar#abc
```

The routes file is generated when Rails starts, including during `webpacker:compile` (or `assets:precompile`).
In development, routes will be updated when a file changes and a request is processed.

To generate routes manually, run:
```bash
$ bundle exec rails webpacker:routes:generate
```

### Options

- `config.webpacker.routes.default_url_options` - defaults used for generating urls. These are merged with `Rails.application.default_url_options`. Default: `{}`
- `config.webpacker.routes.camel_case` - convert route names to camel case. Default: `false`

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
