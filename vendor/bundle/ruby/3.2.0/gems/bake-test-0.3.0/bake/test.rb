# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2024, by Samuel Williams.

def initialize(context)
	super

	require_relative '../lib/bake/test'
end

# Run tests for the given project.
# @parameter root [String] the root directory of the project to run tests for.
def test(root: context.root)
	# Prepare the project for testing, e.g. build native extensions, etc.
	context['before_test']&.call
	
	if method = ::Bake::Test.detect(root)
		::Bake::Test::Runner.public_send(method, root) or abort
	else
		raise "No test runner found!"
	end
end
