# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require_relative "../../../lib/bake/gem/shell"

include Bake::Gem::Shell

# Increment the patch number of the current version.
def patch
	commit([nil, nil, 1], message: "Bump patch version.")
end

# Increment the minor number of the current version.
def minor
	commit([nil, 1, 0], message: "Bump minor version.")
end

# Increment the major number of the current version.
def major
	commit([1, 0, 0], message: "Bump major version.")
end

# Increments the version and commits the changes into a new branch.
#
# @parameter bump [Array(Integer | Nil)] the version bump to apply before publishing, e.g. `0,1,0` to increment minor version number.
# @parameter message [String] the git commit message to use.
def commit(bump, message: "Bump version.")
	release = context.lookup("gem:release")
	helper = release.instance.helper
	gemspec = helper.gemspec
	
	# helper.guard_clean
	
	version_path = context.lookup("gem:release:version:increment").call(bump, message: message)
	
	if version_path
		system("git", "checkout", "-b", "release-v#{gemspec.version}")
		system("git", "add", version_path, chdir: context.root)
		system("git", "commit", "-m", message, chdir: context.root)
	else
		raise "Could not find version number!"
	end
end
