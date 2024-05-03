require 'bake/gem/helper'
require 'sus/fixtures/console/null_logger'

require 'tmpdir'

describe Bake::Gem::Helper do
	let(:helper) {subject.new}
	
	it 'can find the version path' do
		expect(helper.version_path).to be == "lib/bake/gem/version.rb"
	end
	
	with 'repository' do
		let(:helper) {@helper}
		
		def around
			Dir.mktmpdir do |root|
				@helper = subject.new(root)
				
				system("git", "init", chdir: root)
				yield
			end
		end
		
		it 'can update the version' do
			version_path = File.expand_path("version.rb", helper.root)
			File.write(version_path, "VERSION = '0.0.0'\n")
			
			helper.update_version([1, 1, 1], version_path)
			
			expect(File.read(version_path)).to be == "VERSION = '1.1.1'\n"
		end
		
		it 'can guard clean' do
			expect(helper.guard_clean).to be_truthy
		end
		
		it 'raises an error if repository is dirty' do
			File.write(File.expand_path("readme.md", helper.root), "Hello, World!")
			
			expect{helper.guard_clean}.to raise_exception(RuntimeError)
		end
	end
	
	it 'can build gem' do
		package_path = helper.build_gem(signing_key: false)
		expect(File).to be(:exist?, package_path)
	end
end
