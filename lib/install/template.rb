say "Creating JavaScript app source directory"
file Webpacker.config.routes_path.join('.gitignore'), "/index.js\n"

say "Installing all JavaScript dependencies"
run "yarn add webpacker-routes@#{Webpacker::Routes::VERSION} --exact"
