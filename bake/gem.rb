# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative '../lib/bake/gem/helper'
require_relative '../lib/bake/gem/shell'

include Bake::Gem::Shell

def initialize(context)
	super(context)
	
	@helper = Bake::Gem::Helper.new(context.root)
end

attr :helper

# List all the files that will be included in the gem:
def files
	@helper.gemspec.files.each do |path|
		$stdout.puts path
	end
end

# Build the gem into the pkg directory.
def build
	@helper.build_gem
end

# Build and install the gem into system gems.
# @parameter local [Boolean] only use locally available caches.
def install(local: false)
	path = @helper.build_gem
	
	arguments = []
	arguments << "--local" if local
	
	@helper.install_gem(*arguments, path: path)
end

def release(tag: true)
	@helper.guard_clean
	
	version = @helper.gemspec.version
	
	if tag
		name = "v#{version}"
		system("git", "fetch", "--all", "--tags")
		system("git", "tag", name)
	end
	
	begin
		path = @helper.build_gem
		@helper.push_gem(path: path)
	rescue => error
		system("git", "tag", "--delete", name)
		raise
	end
	
	# If we are on a branch, push, otherwise just push the tags (assuming shallow checkout):
	if current_branch
		system("git", "push")
	end
	
	system("git", "push", "--tags")
end

private

# Figure out if there is a current branch, if not, return `nil`.
def current_branch
	# We originally used this but it is not supported by older versions of git.
	# readlines("git", "branch", "--show-current").first&.chomp
	
	readlines("git", "symbolic-ref", "--short", "--quiet", "HEAD").first&.chomp
rescue
	nil
end
