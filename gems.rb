# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Samuel Williams.

source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
end

group :test do
	gem "bake-test"
end
