# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'production/version'

Gem::Specification.new do |spec|
  spec.name          = "production_models"
  spec.version       = Production::VERSION
  spec.authors       = ["Luciano Di Lucrezia"]
  spec.email         = ["luciano.dilucrezia@gmail.com"]
  spec.description   = %q{Access your production models in development environment.}
  spec.summary       = %q{Wraps production ActiveRecord models in a new namespace for easy access and transfer from development environment.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "database_cleaner", "~> 1.0"
end
