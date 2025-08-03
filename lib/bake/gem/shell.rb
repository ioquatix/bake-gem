# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require "console"
require "console/event/spawn"

module Bake
	module Gem
		module Shell
			def system(*arguments, **options)
				Console::Event::Spawn.for(*arguments, **options).emit(self)
				
				begin
					pid = Process.spawn(*arguments, **options)
					return yield if block_given?
				ensure
					pid, status = Process.wait2(pid) if pid
					
					unless status.success?
						raise "Failed to execute #{arguments}: #{status}!"
					end
					
					return true
				end
			end
			
			def execute(*arguments, **options)
				Console::Event::Spawn.for(*arguments, **options).emit(self)
				
				IO.pipe do |input, output|
					pid = Process.spawn(*arguments, out: output, **options)
					output.close
					
					begin
						return yield(input)
					ensure
						pid, status = Process.wait2(pid)
						
						unless status.success?
							raise "Failed to execute #{arguments}: #{status}!"
						end
					end
				end
			end
			
			def readlines(*arguments, **options)
				execute(*arguments, **options) do |output|
					return output.readlines
				end
			end
		end
	end
end
