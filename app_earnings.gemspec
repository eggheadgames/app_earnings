# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "app_earnings"
  spec.version       = "1.0.0"
  spec.authors       = ["Egghead Games", "André Luis Leal Cardoso Junior", "Michael Mee"]
  spec.email         = ["support@eggheadgames.com"]
  spec.summary       = %q{Process app store csv report files into a text/json summary by application and iap}
  spec.description   = <<-EOF
Allows easy calculation of revenue sharing by app and in-app purchases. 
Munges the monthly CSV reports from Google Play or Amazon Android app stores. 
Does Amazon currency conversions and verifies against payment amounts.
EOF
  spec.homepage      = "http://github.com/eggheadgames/app_earnings"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   << 'app_earnings'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.18.0"
  spec.add_dependency "currencies", "~> 0.4.2"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop", "~> 0.18.1"
  spec.add_development_dependency "ruby-lint", "~> 1.1.0"
  spec.add_development_dependency "rspec", "~> 2.14"
end
