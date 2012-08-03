# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rgdb/version"

Gem::Specification.new do |s|
  s.name        = "rgdb"
  s.version     = Rgdb::VERSION
  s.authors     = ["yafei Lee"]
  s.email       = ["lyfi2003@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{gdb debug wrapper for net-ssh}
  s.description = %q{gdb debug wrapper for net-ssh}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
