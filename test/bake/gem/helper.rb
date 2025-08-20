# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "bake/gem/helper"
require "sus/fixtures/console/null_logger"

require "tmpdir"

describe Bake::Gem::Helper do
	let(:helper) {subject.new}
	
	it "can find the version path" do
		expect(helper.version_path).to be == "lib/bake/gem/version.rb"
	end
	
	with "repository" do
		let(:helper) {@helper}
		
		def around
			Dir.mktmpdir do |root|
				@helper = subject.new(root)
				
				system("git", "init", chdir: root)
				yield
			end
		end
		
		it "can update the version" do
			version_path = File.expand_path("version.rb", helper.root)
			File.write(version_path, "VERSION = '0.0.0'\n")
			
			helper.update_version([1, 1, 1], version_path)
			
			expect(File.read(version_path)).to be == "VERSION = '1.1.1'\n"
		end
		
		it "can guard clean" do
			expect(helper.guard_clean).to be_truthy
		end
		
		it "raises an error if repository is dirty" do
			File.write(File.expand_path("readme.md", helper.root), "Hello, World!")
			
			expect{helper.guard_clean}.to raise_exception(RuntimeError)
		end
		
		it "can build gem in worktree" do
			# Create some dummy files:
			FileUtils.mkdir_p(File.expand_path("lib", helper.root))
			File.write(File.expand_path("lib/test_gem.rb", helper.root), "# Test gem main file")
			File.write(File.expand_path("readme.md", helper.root), "# Test Gem")
			
			# Create a minimal gemspec for testing that uses git to find files
			gemspec_content = <<~GEMSPEC
				Gem::Specification.new do |spec|
					spec.name = "test-gem"
					spec.version = "1.0.0"
					spec.authors = ["Test"]
					spec.email = ["test@example.com"]
					spec.summary = "Test gem"
					spec.files = Dir.glob("**/*")
				end
			GEMSPEC
			
			File.write(File.expand_path("test-gem.gemspec", helper.root), gemspec_content)
			
			# Create an initial commit so we have a HEAD to create worktree from
			system("git", "add", ".", chdir: helper.root)
			system("git", "-c", "user.email=test@test.com", "-c", "user.name=Test User", "commit", "-m", "Initial commit", chdir: helper.root)
			
			package_path = helper.build_gem_in_worktree(signing_key: false)
			expect(File).to be(:exist?, package_path)
			
			# Verify the gem was built in the original location, not worktree
			expect(package_path).to be(:start_with?, helper.root)
		end
	end
	
	it "can build gem" do
		package_path = helper.build_gem(signing_key: false)
		expect(File).to be(:exist?, package_path)
	end
end
