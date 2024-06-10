# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

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
# @parameter root [String] The root directory to build the gem into. Defaults to `pkg`.
# @parameter signing_key [Boolean] Whether to use a signing key.
def build(root: "pkg", signing_key: nil)
	@helper.build_gem(root: root, signing_key: signing_key)
end

# Build and install the gem into system gems.
# @parameter local [Boolean] only use locally available caches.
def install(local: false)
	# For installing the gem, don't bother with signinng it:
	path = @helper.build_gem(signing_key: false)
	
	arguments = []
	arguments << "--local" if local
	
	@helper.install_gem(*arguments, path: path)
end

def release(tag: true)
	@helper.guard_clean
	@helper.guard_default_branch
	
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
