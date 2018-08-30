# Webpacker::Routes
Short description and motivation.

## TODO

- handle "special" options in urlFor
  - only_path - If true, the relative URL is returned. Defaults to false.
  - protocol - The protocol to connect to. Defaults to 'http'.
  - host - Specifies the host the link should be targeted at. If :only_path is false, this option must be provided either explicitly, or via - - - default_url_options.
  - subdomain - Specifies the subdomain of the link, using the tld_length to split the subdomain from the host. If false, removes all subdomains - from the host part of the link.
  - domain - Specifies the domain of the link, using the tld_length to split the domain from the host.
  - tld_length - Number of labels the TLD id composed of, only used if :subdomain or :domain are supplied. Defaults to ActionDispatch::Http::URL.tld_length, which in turn defaults to 1.
  - port - Optionally specify the port to connect to.
  - anchor - An anchor name to be appended to the path.
  - trailing_slash - If true, adds a trailing slash, as in “/archive/2009/”
  - script_name - Specifies application path relative to domain root. If provided, prepends application path.
- fix handle_positional_args in rails
- somehow generate routes automatically in development
- unicode route names
- relative_url_root
- default_url_options
- camelcase option

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'webpacker-routes'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install webpacker-routes
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
