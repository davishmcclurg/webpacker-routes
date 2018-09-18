say "Creating JavaScript app source directory"
directory "#{__dir__}/javascript", Webpacker.config.source_path.join('routes')

say "Installing all JavaScript dependencies"
run "yarn add webpacker-routes@0.0.4 --exact"
