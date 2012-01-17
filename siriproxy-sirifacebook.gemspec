# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-sirifacebook"
  s.version     = "0.0.1.1" 
  s.authors     = ["TheKleini666"]
  s.email       = ["support@revolution-apps.com"]
  s.homepage    = "http://revolution-apps.co,"
  s.summary     = %q{Facebook for siri proxy}
  s.description = %q{This is a plugin, which connects to facebook and it has many commands for facebook.}

  s.rubyforge_project = "siriproxy-sirifacebook"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "httparty"
end
