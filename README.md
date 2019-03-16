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
import { root_path } from 'routes'

console.log(root_path())
```

The routes file is generated when Rails starts, including during `webpacker:compile` (or `assets:precompile`).
In development, routes will be updated when a file changes and a request is processed.

To generate routes manually, run:
```bash
$ bundle exec rails webpacker:routes:generate
```

### Options

- `config.webpacker.routes.default_url_options` - defaults used for generating urls. These are merged with `Rails.application.default_url_options`.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Todo

- support all valid route names
- camelcase
