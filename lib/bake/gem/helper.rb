# frozen_string_literal: true

# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rubygems'
require 'rubygems/package'

module Bake
	module Gem
		class Helper
			include Shell
			
			def initialize(root = Dir.pwd, gemspec: nil)
				@root = root
				@gemspec = gemspec || self.find_gemspec
			end
			
			attr :gemspec
			
			def version_path
				@gemspec&.files.grep(/lib(.*?)version.rb/).first
			end
			
			VERSION_PATTERN = /VERSION = ['"](?<value>\d+\.\d+\.\d+)(?<pre>.*?)['"]/
			
			def update_version(bump)
				return unless version_path = self.version_path
				
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
					yield version if block_given?
					
					File.write(version_path, lines.join)
					
					return version_path
				end
			end
			
			def guard_clean
				lines = readlines("git", "status", "--porcelain")
				
				if lines.any?
					raise "Repository has uncommited changes!\n#{lines.join('')}"
				end
			end
			
			# @returns [String] The path to the built gem package.
			def build_gem
				Gem::Package.build(@gemspec)
			end
			
			def install_gem(*arguments)
				execute("gem", "install", @gemspec.file_name, *arguments)
			end
			
			def push_gem(*arguments)
				execute("gem", "push", @gemspec.file_name, *arguments)
			end
			
			private
			
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
