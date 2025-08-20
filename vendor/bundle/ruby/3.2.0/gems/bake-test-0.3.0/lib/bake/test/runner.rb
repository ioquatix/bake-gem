# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

module Bake
	module Test
		module Runner
			def self.rspec(root)
				system("bundle", "exec", "rspec", chdir: root)
			end
			
			def self.sus(root)
				system("bundle", "exec", "sus", chdir: root)
			end

			def self.minitest(root)
				system("bundle", "exec", "minitest", chdir: root)
			end

			def self.rake(root)
				system("bundle", "exec", "rake", "test", chdir: root)
			end
		end
	end
end
