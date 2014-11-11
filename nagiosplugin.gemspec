# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nagiosplugin'

Gem::Specification.new do |spec|
  spec.name        = 'nagiosplugin'
  spec.version     = Nagios::Plugin::VERSION
  spec.authors     = ['Björn Albers']
  spec.email       = ['bjoernalbers@gmail.com']
  spec.homepage    = 'https://github.com/bjoernalbers/nagiosplugin'
  spec.summary     = "#{spec.name}-#{spec.version}"
  spec.description = 'A Nagios Plugin framework that fits on a folded napkin.'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n") - %w(.gitignore .travis.yml)
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'rspec', '~> 3.1'
end
