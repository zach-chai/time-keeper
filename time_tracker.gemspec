
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "time_tracker/version"

Gem::Specification.new do |spec|
  spec.name          = "time_tracker"
  spec.version       = TimeTracker::VERSION
  spec.authors       = ["Zachary Chai"]
  spec.email         = ["zachary.chai@outlook.com"]

  spec.summary       = %q{Automate time tracking}
  spec.description   = %q{Automate time tracking by integrating calendar with timesheets}
  spec.homepage      = "https://github.com/zach-chai/time-tracker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency "harvest-api", "~> 0.1"
  spec.add_dependency "google-api-client", "~> 0.17"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug"
end