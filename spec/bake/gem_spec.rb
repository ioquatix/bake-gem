# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

RSpec.describe Bake::Gem do
	it "has a version number" do
		expect(Bake::Gem::VERSION).not_to be nil
	end
end
