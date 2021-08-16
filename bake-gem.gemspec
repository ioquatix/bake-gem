
require_relative "lib/bake/gem/version"

Gem::Specification.new do |spec|
	spec.name = "bake-gem"
	spec.version = Bake::Gem::VERSION
	
	spec.summary = "Release management for Ruby gems."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/bake-gem"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{bake,lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.3.0"
end
