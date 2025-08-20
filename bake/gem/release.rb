
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

# Bump the patch version and release the gem in one command.
# @parameter tag [Boolean] Whether to tag the release.
def patch(tag: true)
	version_commit_task = context.lookup("gem:release:version:commit")
	version_commit_task.call([nil, nil, 1], message: "Bump patch version.")
	
	release_task = context.lookup("gem:release")
	release_task.call(tag: tag)
end

# Bump the minor version and release the gem in one command.
# @parameter tag [Boolean] Whether to tag the release.
def minor(tag: true)
	version_commit_task = context.lookup("gem:release:version:commit")
	version_commit_task.call([nil, 1, 0], message: "Bump minor version.")
	
	release_task = context.lookup("gem:release")
	release_task.call(tag: tag)
end

# Bump the major version and release the gem in one command.
# @parameter tag [Boolean] Whether to tag the release.
def major(tag: true)
	version_commit_task = context.lookup("gem:release:version:commit")
	version_commit_task.call([1, 0, 0], message: "Bump major version.")
	
	release_task = context.lookup("gem:release")
	release_task.call(tag: tag)
end
