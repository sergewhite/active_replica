# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_replica/version'

Gem::Specification.new do |spec|
  spec.name          = "active_replica"
  spec.version       = ActiveReplica::VERSION
  spec.authors       = ["Matthew Rudy Jacobs"]
  spec.email         = ["matthewrudyjacobs@gmail.com"]

  spec.summary       = %q{Simple, performant Read-Only replicas with ActiveRecord}
  spec.description   = %q{Add shards, and switch between them for key tasks}
  spec.homepage      = "https://github.com/gogovan/active_replica"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 4.2.0', '< 5.0.0'
  spec.add_dependency 'activerecord', '>= 4.2.0', '< 5.0.0'
  spec.add_dependency 'concurrent-ruby', '~> 1.0.0.pre2', '< 2.0.0'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
