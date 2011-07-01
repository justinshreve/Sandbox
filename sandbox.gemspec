# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'sandbox.rb'

Gem::Specification.new do |s|
  s.name        = "sandbox"
  s.version     = sandbox::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Justin Shreve"]
  s.email       = ["justin.shreve@gmail.com"]
  s.homepage    = "http://github.com/justinshreve/Sandbox"
  s.summary     = %q{Add entries to your hosts file, and disable/enable their use}
  s.description = %q{Sandbox manages part of your hosts file and lets you specify domains sandbox to point locally or remotely to. You can quickly enable or disable sandboxing of those domains.}
  s.has_rdoc = false

  s.files              = `git ls-files`.split("\n")
  s.executables        = %w(sandbox)
  s.require_paths      = ["lib"]
end
