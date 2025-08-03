# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require "rubygems"
require "rubygems/package"
require "fileutils"

require_relative "shell"

module Bake
	module Gem
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
			
			def initialize(parts, suffix)
				@parts = parts
				@suffix = suffix
			end
			
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
		
		class Helper
			include Shell
			
			def initialize(root = Dir.pwd, gemspec: nil)
				@root = root
				@gemspec = gemspec || find_gemspec
			end
			
			attr :root
			attr :gemspec
			
			def version_path
				@gemspec&.files.grep(/lib(.*?)\/version.rb/).first
			end
			
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
			
			def install_gem(*arguments, path: @gemspec.file_name)
				system("gem", "install", path, *arguments)
			end
			
			def push_gem(*arguments, path: @gemspec.file_name)
				system("gem", "push", path, *arguments)
			end
			
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
