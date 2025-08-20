# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require "rubygems"
require "rubygems/package"
require "fileutils"

require_relative "shell"

# @namespace
module Bake
	# @namespace
	# @namespace
	module Gem
		# Represents a gem version with support for parsing and incrementing version numbers.
		class Version
			LINE_PATTERN = /VERSION = ['"](?<version>(?<parts>\d+\.\d+\.\d+)(-(?<suffix>.*?))?)['"]/
			
			# If the line contains a version constant, update it using the provided block.
			def self.update_version(line)
				if match = line.match(LINE_PATTERN)
					parts = match[:parts].split(/\./).map(&:to_i)
					suffix = match[:suffix]
					
					version = self.new(parts, suffix)
					
					yield version
					
					line.sub!(match[:version], version.join)
				end
			end
			
			# Initialize a new version with the given parts and optional suffix.
			# @parameter parts [Array(Integer)] The version number parts (e.g., [1, 2, 3] for "1.2.3").
			# @parameter suffix [String | Nil] The optional version suffix (e.g., "alpha", "beta").
			def initialize(parts, suffix)
				@parts = parts
				@suffix = suffix
			end
			
			# Check if this version represents a release version.
			# @returns [Boolean] True if the version has no suffix, indicating it's a release version.
			def release?
				@suffix.nil?
			end
			
			# Join all parts together to form a version string.
			def join
				if @suffix
					return "#{@parts.join('.')}-#{@suffix}"
				else
					return @parts.join(".")
				end
			end
			
			# The version string with a "v" prefix.
			def to_s
				"v#{join}"
			end
			
			# Increment the version according to the provided bump specification.
			# @parameter bump [Array(Integer)] Array specifying how to increment each version part.
			# @returns [Version] Self, for method chaining.
			def increment(bump)
				bump.each_with_index do |increment, index|
					if index > @parts.size
						@suffix = bump[index..-1].join(".")
						break
					end
					
					if increment == 1
						@parts[index] += 1
					elsif increment == 0
						@parts[index] = 0
					end
				end
				
				return self
			end
		end
		
		# Helper class for performing gem-related operations like building, installing, and publishing gems.
		class Helper
			include Shell
			
			# Initialize a new helper with the specified root directory and optional gemspec.
			# @parameter root [String] The root directory of the gem project.
			# @parameter gemspec [Gem::Specification | Nil] The gemspec to use, or nil to find it automatically.
			def initialize(root = Dir.pwd, gemspec: nil)
				@root = root
				@gemspec = gemspec || find_gemspec
			end
			
			# @attribute [String] The root directory of the gem project.
			attr :root
			
			# @attribute [Gem::Specification] The gemspec for the gem.
			attr :gemspec
			
			# Find the path to the version.rb file in the gem.
			# @returns [String | Nil] The path to the version file, or nil if not found.
			def version_path
				@gemspec&.files.grep(/lib(.*?)\/version.rb/).first
			end
			
			# Update the version number in the version file according to the bump specification.
			# @parameter bump [Array(Integer)] Array specifying how to increment each version part.
			# @parameter version_path [String] The path to the version file.
			# @returns [String | Boolean] The path to the version file if updated, or false if no version file found.
			def update_version(bump, version_path = self.version_path)
				return false unless version_path
				
				lines = File.readlines(version_path)
				new_version = nil
				
				lines.each do |line|
					Version.update_version(line) do |version|
						new_version = version.increment(bump)
					end
				end
				
				if new_version
					File.write(version_path, lines.join)
					
					if block_given?
						yield new_version
					end
					
					return version_path
				end
			end
			
			# Verify that the repository has no uncommitted changes.
			# @returns [Boolean] True if the repository is clean.
			# @raises [RuntimeError] If there are uncommitted changes in the repository.
			def guard_clean
				lines = readlines("git", "status", "--porcelain", chdir: @root)
				
				if lines.any?
					raise "Repository has uncommited changes!\n#{lines.join('')}"
				end
				
				return true
			end
			
			# @parameter root [String] The root path for package files.
			# @parameter signing_key [String | Nil] The signing key to use for signing the package.
			# @returns [String] The path to the built gem package.
			def build_gem(root: "pkg", signing_key: nil)
				# Ensure the output directory exists:
				FileUtils.mkdir_p("pkg")
				
				output_path = File.join("pkg", @gemspec.file_name)
				
				if signing_key == false
					@gemspec.signing_key = nil
				elsif signing_key.is_a?(String)
					@gemspec.signing_key = signing_key
				elsif signing_key == true and @gemspec.signing_key.nil?
					raise ArgumentError, "Signing key is required for signing the gem, but none was specified by the gemspec."
				end
				
				::Gem::Package.build(@gemspec, false, false, output_path)
			end
			
			# Install the gem using the `gem install` command.
			# @parameter arguments [Array] Additional arguments to pass to `gem install`.
			# @parameter path [String] The path to the gem file to install.
			def install_gem(*arguments, path: @gemspec.file_name)
				system("gem", "install", path, *arguments)
			end
			
			# Push the gem to a gem repository using the `gem push` command.
			# @parameter arguments [Array] Additional arguments to pass to `gem push`.
			# @parameter path [String] The path to the gem file to push.
			def push_gem(*arguments, path: @gemspec.file_name)
				system("gem", "push", path, *arguments)
			end
			
			# Find a gemspec file in the root directory.
			# @parameter glob [String] The glob pattern to use for finding gemspec files.
			# @returns [Gem::Specification | Nil] The loaded gemspec, or nil if none found.
			# @raises [RuntimeError] If multiple gemspec files are found.
			def find_gemspec(glob = "*.gemspec")
				paths = Dir.glob(glob, base: @root).sort
				
				if paths.size > 1
					raise "Multiple gemspecs found: #{paths}, please specify one!"
				end
				
				if path = paths.first
					return ::Gem::Specification.load(path)
				end
			end
		end
	end
end
