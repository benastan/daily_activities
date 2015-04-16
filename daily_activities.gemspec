# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'daily_activities/version'

Gem::Specification.new do |spec|
  spec.name          = "daily_activities"
  spec.version       = DailyActivities::VERSION
  spec.authors       = ["Ben Bergstein"]
  spec.email         = ["bennyjbergstein@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "capybara-webkit"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "shotgun"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "launchy"
  spec.add_dependency "interactor"
  spec.add_dependency "sinatra"
  spec.add_dependency "pg"
  spec.add_dependency "sequel"
  spec.add_dependency "foreman"
  spec.add_dependency "haml"
  spec.add_dependency "unicorn"
  spec.add_dependency "faraday"
end
