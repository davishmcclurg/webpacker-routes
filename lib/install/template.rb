say "Creating JavaScript app source directory"
directory "#{__dir__}/javascript", Webpacker.config.source_path.join('routes')

say "Installing all JavaScript dependencies"
run "yarn add route-parser@0.0.5 --exact"
