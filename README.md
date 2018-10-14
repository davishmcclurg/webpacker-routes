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

Finally, generate your routes file:
```bash
$ bundle exec rails webpacker:routes:generate
```

You will need to regenerate the routes file whenever you add a new Rails route.

## Usage
Import individual routes from any Webpacker-compiled file:

```javascript
import { root_path } from 'routes'

console.log(root_path())
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## TODO

- fix handle_positional_args in rails
- somehow generate routes automatically in development
  - to_prepare?
- support all valid route names
- default_url_options
- relative_url_root
- camelcase
