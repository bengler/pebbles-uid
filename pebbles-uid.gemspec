# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pebbles-uid/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Katrina Owen"]
  gem.email         = ["katrina.owen@gmail.com"]
  gem.description   = %q{Handle pebble UIDs conveniently.}
  gem.summary       = %q{Unique identifiers in the Pebblestack universe, in the format species[.genus]:path$oid, where the path is a dot-delimited set of labels, the first of which (realm) is required.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pebbles-uid"
  gem.require_paths = ["lib"]
  gem.version       = Pebbles::Uid::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "its"
end
