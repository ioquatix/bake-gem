# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

module Bake
	module Test
		def self.detect(root)
			if exist?(root, "spec")
				return :rspec
			elsif exist?(root, "config/sus.rb")
				return :sus
			elsif exist?(root, "test")
				return :sus
			elsif exist?(root, "Rakefile") || exist?(root, "rakefile")
				return :rake
			end
		end

		def self.exist?(root, path)
			File.exist?(File.join(root, path))
		end
	end
end
