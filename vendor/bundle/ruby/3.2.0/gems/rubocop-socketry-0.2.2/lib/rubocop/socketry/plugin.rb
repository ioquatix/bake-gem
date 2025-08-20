# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "lint_roller"
require_relative "version"

module RuboCop
	module Socketry
		# Represents a LintRoller plugin that provides RuboCop rules for Socketry projects.
		# This plugin integrates custom RuboCop cops and configuration into the LintRoller system.
		class Plugin < LintRoller::Plugin
			# Initialize the plugin with version information.
			def initialize(...)
				super
				@version = RuboCop::Socketry::VERSION
			end
			
			# Get information about this plugin for the LintRoller system.
			# @returns [LintRoller::About] Plugin metadata including name, version, and description.
			def about
				LintRoller::About.new(
					name: "rubocop-socketry",
					version: @version,
					homepage: "https://github.com/socketry/rubocop-socketry",
					description: "RuboCop rules for Socketry projects."
				)
			end
			
			# Define the rules configuration for this plugin.
			# @parameter context [Object] The LintRoller context object.
			# @returns [LintRoller::Rules] Rules configuration specifying the path to the default RuboCop config.
			def rules(context)
				LintRoller::Rules.new(
					type: :path,
					config_format: :rubocop,
					value: File.expand_path("config.yaml", __dir__),
				)
			end
		end
	end
end 
