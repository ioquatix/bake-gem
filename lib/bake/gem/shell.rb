# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2025, by Samuel Williams.

require "console"
require "console/event/spawn"

# @namespace
module Bake
	# @namespace
	module Gem
		# Provides shell command execution methods with proper logging and error handling.
		# Provides shell command execution methods with proper logging and error handling.
		module Shell
			# Execute a system command with logging and error handling.
			# @parameter arguments [Array] The command and its arguments to execute.
			# @parameter options [Hash] Additional options to pass to Process.spawn.
			# @returns [Boolean] True if the command executed successfully.
			# @raises [RuntimeError] If the command fails.
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
			
			# Execute a command and yield its output to a block.
			# @parameter arguments [Array] The command and its arguments to execute.
			# @parameter options [Hash] Additional options to pass to Process.spawn.
			# @yields {|input| ...} The input stream from the executed command.
			# @returns [Object] The return value of the block.
			# @raises [RuntimeError] If the command fails.
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
			
			# Execute a command and return its output as an array of lines.
			# @parameter arguments [Array] The command and its arguments to execute.
			# @parameter options [Hash] Additional options to pass to Process.spawn.
			# @returns [Array(String)] The output lines from the executed command.
			# @raises [RuntimeError] If the command fails.
			def readlines(*arguments, **options)
				execute(*arguments, **options) do |output|
					return output.readlines
				end
			end
		end
	end
end
