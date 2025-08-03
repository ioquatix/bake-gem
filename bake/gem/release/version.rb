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

# Scans the files listed in the gemspec for a file named `version.rb`. Extracts the VERSION constant and updates it according to the version bump.
#
# @parameter bump [Array(Integer | Nil)] the version bump to apply before publishing, e.g. `0,1,0` to increment minor version number.
# @parameter message [String] the git commit message to use.
def increment(bump, message: "Bump version.")
	release = context.lookup("gem:release")
	helper = release.instance.helper
	gemspec = helper.gemspec
	
	helper.update_version(bump) do |version|
		Console.logger.info(self) {"Updated version: #{version}"}
		
		# Ensure that any subsequent tasks use the correct version!
		gemspec.version = version.join
		
		after_increment(version)
	end
	
	return {
		version: gemspec.version,
		version_path: helper.version_path,
	}
end

# Increments the version and commits the changes on the current branch.
#
# @parameter bump [Array(Integer | Nil)] the version bump to apply before publishing, e.g. `0,1,0` to increment minor version number.
# @parameter message [String] the git commit message to use.
def commit(bump, message: "Bump version.")
	release = context.lookup("gem:release")
	helper = release.instance.helper
	
	helper.guard_clean
	
	version_path = increment(bump, message: message)
	
	if version_path
		system("git", "add", "--all", chdir: context.root)
		system("git", "commit", "-m", message, chdir: context.root)
	else
		raise "Could not find version number!"
	end
	
	return {
		version: helper.gemspec.version,
		version_path: version_path,
	}
end

protected

def after_increment(version)
	context["after_gem_release_version_increment"]&.call(version)
end
