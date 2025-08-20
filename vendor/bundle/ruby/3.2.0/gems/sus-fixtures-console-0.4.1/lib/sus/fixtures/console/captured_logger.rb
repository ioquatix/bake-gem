# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "sus/shared"
require "console"
require "console/capture"
require "console/logger"

module Sus
	module Fixtures
		module Console
			# Shared context for capturing console output during tests.
			# Provides access to captured log messages and helper methods for testing console logging.
			CapturedLogger = Sus::Shared("captured logger") do
				# @attribute [Console::Capture] Captures console output for inspection.
				let(:console_capture) {::Console::Capture.new}
				# @attribute [Console::Logger] Logger configured to capture output at DEBUG level.
				let(:console_logger) {::Console::Logger.new(console_capture, level: ::Console::Logger::DEBUG)}
				
				# Set up console logger before test execution and clean up afterwards.
				def around
					::Console.logger = console_logger
					super
				ensure
					::Console.logger = nil
				end
				
				# Create an expectation for the console capture.
				# @returns [Object] An expectation object for the console capture.
				def expect_console
					expect(console_capture)
				end
				
				# Create a matcher for checking logged messages with specific fields.
				# @parameter fields [Hash] Key-value pairs to match in logged messages.
				# @returns [Object] A matcher that checks for logged messages containing the specified fields.
				def have_logged(**fields)
					have_value(have_keys(**fields))
				end
			end
		end
	end
end
