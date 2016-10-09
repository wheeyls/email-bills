# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_bills/version'

Gem::Specification.new do |spec|
  spec.name          = "email_bills"
  spec.version       = EmailBills::VERSION
  spec.authors       = ["Michael Wheeler"]
  spec.email         = ["mwheeler@g2crowd.com"]

  spec.summary       = %q{Check an email inbox, to find and split bills}
  spec.homepage      = "https://github.com/wheeyls/email-bills"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'mail', '~> 2.6'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
end
