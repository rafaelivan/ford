# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ford/version"

Gem::Specification.new do |s|
  s.add_dependency 'logger'
  
  s.name        = "ford"
  s.version     = Ford::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bruno Bueno","Débora Setton", "Rafael Barbolo", "Rafael Ivan"]
  s.email       = ["bruno.bueno@infosimples.com.br", "debora.setton@infosimples.com.br", "rafael.barbolo@infosimples.com.br", "rafael.ivan@infosimples.com.br"]
  s.homepage    = "http://www.infosimples.com.br/en/"
  s.summary     = %q{Ruby scalable pipeline framework}
  s.description = %q{Ford allows you to split a ruby script into stages of a scalable and performant pipeline}

  s.rubyforge_project = "ford"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
