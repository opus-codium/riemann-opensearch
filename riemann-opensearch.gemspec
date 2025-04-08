# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "riemann-opensearch"
  spec.version = "0.0.1"
  spec.authors = ["Romain Tartière"]
  spec.email = ["romain@blogreen.org"]

  spec.summary = "Send OpenSearch metrics to Riemann"
  spec.homepage = "https://github.com/opus-codium/riemann-opensearch"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables =
    spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday-net_http_persistent"
  spec.add_dependency "opensearch-ruby", "~> 3.0"
  spec.add_dependency "riemann-tools", "~> 1.0"
end
