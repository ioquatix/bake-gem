source "https://rubygems.org"

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
end
