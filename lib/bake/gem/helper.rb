# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2023, by Samuel Williams.

require 'rubygems'
require 'rubygems/package'
require 'fileutils'

require_relative 'shell'

module Bake
	module Gem
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
			
			VERSION_PATTERN = /VERSION = ['"](?<value>\d+\.\d+\.\d+)(?<pre>.*?)['"]/
			
			def update_version(bump, version_path = self.version_path)
				return false unless version_path
				
				lines = File.readlines(version_path)
				version = nil
				
				lines.each do |line|
					if match = line.match(VERSION_PATTERN)
						version = match[:value].split(/\./).map(&:to_i)
						bump.each_with_index do |increment, index|
							if increment == 1
								version[index] += 1
							elsif increment == 0
								version[index] = 0
							end
						end
						
						line.sub!(match[:value], version.join('.'))
					end
				end
				
				if version
					if block_given?
						yield version
					end
					
					File.write(version_path, lines.join)
					
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
				
				output_path = File.join('pkg', @gemspec.file_name)
				
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
