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

require_relative '../../../lib/bake/gem/shell'

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
	release = context.lookup('gem:release')
	helper = release.instance.helper
	gemspec = helper.gemspec
	
	# helper.guard_clean
	
	version_path = context.lookup('gem:release:version:increment').call(bump, message: message)
	
	if version_path
		system("git", "checkout", "-b", "release-v#{gemspec.version}")
		system("git", "add", version_path, chdir: context.root)
		system("git", "commit", "-m", message, chdir: context.root)
	else
		raise "Could not find version number!"
	end
end
