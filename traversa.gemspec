# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'traversa/version'

Gem::Specification.new do |spec|
  spec.name          = "traversa"
  spec.version       = Traversa::VERSION
  spec.authors       = ["Sam Brauer"]
  spec.email         = ["sam.brauer@gmail.com"]

  spec.summary       = %q{A resource-oriented web microframework}
  spec.homepage      = "https://github.com/sbrauer/traversa"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency 'sinatra', '1.4.5'
end
