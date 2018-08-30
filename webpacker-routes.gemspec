$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "webpacker/routes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "webpacker-routes"
  s.version     = Webpacker::Routes::VERSION
  s.authors     = ["David Harsha"]
  s.email       = ["davishmcclurg@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Webpacker::Routes."
  s.description = "TODO: Description of Webpacker::Routes."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1"

  s.add_development_dependency "sqlite3"
end
