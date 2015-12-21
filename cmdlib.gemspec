# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cmdlib/version'

Gem::Specification.new do |spec|
  spec.name          = "cmdlib"
  spec.version       = Cmdlib::VERSION
  spec.authors       = ["Anton S. Gerasimov"]
  spec.email         = ["gera_box@mail.ru"]
  spec.summary       = %q{Simple constructor of CLI (Command Line Interface) handler.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/gera-gas/cmdlib"
  spec.license       = "MIT"
  spec.files         = ["lib/cmdlib.rb", "lib/cmdlib/command.rb", "lib/cmdlib/describe.rb", "lib/cmdlib/handler.rb", "lib/cmdlib/option.rb", "lib/cmdlib/version.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
