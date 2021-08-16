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

require_relative '../../lib/bake/bundler/shell'

include Bake::Bundler::Shell

# Increment the patch number of the current version.
def patch
	increment([nil, nil, 1], message: "Bump patch version.")
end

# Increment the minor number of the current version.
def minor
	increment([nil, 1, 0], message: "Bump minor version.")
end

# Increment the major number of the current version.
def major
	increment([1, 0, 0], message: "Bump major version.")
end

# Scans the files listed in the gemspec for a file named `version.rb`. Extracts the VERSION constant and updates it according to the version bump. Commits the changes to git using the specified message.
#
# @parameter bump [Array(Integer | Nil)] the version bump to apply before publishing, e.g. `0,1,0` to increment minor version number.
# @parameter message [String] the git commit message to use.
def commit(bump, message: "Bump version.")
	release = context.lookup('bundler:release')
	helper = release.instance.helper
	gemspec = helper.gemspec
	
	version_path = helper.update_version(bump) do |version|
		version_string = version.join('.')
		
		Console.logger.info(self) {"Updated version to #{version_string}"}
		
		# Ensure that any subsequent tasks use the correct version!
		gemspec.version = Gem::Version.new(version_string)
	end
	
	if version_path
		File.write(version_path, lines.join)
		
		system("git", "add", version_path, chdir: context.root)
		system("git", "commit", "-m", message, chdir: context.root)
		
		version_string = version.join('.')
		
		Console.logger.info(self) {"Updated version to #{version_string}"}
		
		# Ensure that any subsequent tasks use the correct version!
		gemspec.version = Gem::Version.new(version_string)
	else
		raise "Could not find version number!"
	end
end

private

def release(*arguments, **options)
	release = context.lookup('bundler:release')
	helper = release.instance.helper
	
	changes = readlines("git", "status", "--porcelain")
	
	if changes.any?
		puts "Uncommitted modifications detected:"
		changes.each do |change|
			puts change
		end
	else
		last_commit = readlines("git", "log", "-1", "--oneline").first
		
		unless last_commit =~ /version bump|bump version/i
			increment(*arguments, **options)
		end
		
		release.call
	end
end
