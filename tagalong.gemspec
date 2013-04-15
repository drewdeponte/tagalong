# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tagalong/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew De Ponte", "Russ Cloak"]
  gem.email         = ["cyphactor@gmail.com", "russcloak@gmail.com"]
  gem.description   = %q{A Rails tagging plugin that makes sense.}
  gem.summary       = %q{A Rails tagging plugin that makes sense.}
  gem.homepage      = "http://github.com/cyphactor/tagalong"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tagalong"
  gem.require_paths = ["lib"]
  gem.version       = Tagalong::VERSION

  gem.add_dependency "activerecord", ">= 3.0.0"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "sunspot_rails"
  gem.add_development_dependency "sunspot_solr"
  gem.add_development_dependency "sunspot_test"
end
