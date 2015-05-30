# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'upgrademe/version'

Gem::Specification.new do |spec|
  spec.name          = "upgrademe"
  spec.version       = Upgrademe::VERSION
  spec.authors       = ["Ryan Pei"]
  spec.email         = ["rpei@pivotal.io"]

  spec.summary       = "Tells you how to upgrade your PCF products"
  spec.description   = "Answer a few questions to help me figure out what you need to do to get your PCF deployment upgraded"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = "upgrademe"
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'open4'
  spec.add_dependency 'highline'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '>= 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.23.0'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rubyzip'
end
