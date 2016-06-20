# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boyer_moore/version'

Gem::Specification.new do |spec|
  spec.name          = "boyer_moore"
  spec.version       = BoyerMoore::VERSION
  spec.authors       = ["Sri Harsha Kappala"]
  spec.email         = ["sriharsha.kappala@hotmail.com"]
  spec.licenses      = ['MIT']
  spec.summary       = "Ruby wrapper for BoyerMoore algorithm - The fastest search strategy, ever!"
  spec.description   = "Ruby wrapper for Boyer-Moore - The fastest search strategy, ever!"
  spec.homepage      = "https://github.com/sriharshakappala/boyer_moore"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
