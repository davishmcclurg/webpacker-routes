$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "webpacker/routes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "webpacker-routes"
  s.version     = Webpacker::Routes::VERSION
  s.authors     = ["David Harsha"]
  s.email       = ["davishmcclurg@gmail.com"]
  s.homepage    = "https://github.com/davishmcclurg/webpacker-routes"
  s.summary     = "Convert Rails routes to JavaScript modules"
  s.license     = "MIT"

  s.metadata = {
      'source_code_uri' => 'https://github.com/davishmcclurg/webpacker-routes',
  }

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "railties", ">= 4.2"
  s.add_dependency "webpacker", ">= 3"
  s.add_development_dependency "execjs"
end
