# Getting Started

This guide explains how to use `bake-gem` to release gems.

## Installation

Add the `bake-gem` gem to your project:

``` bash
$ bundle add bake-gem
```

You may prefer to keep it in a separate `maintenance` group:

``` ruby
group :maintenance, optional: true do
	gem "bake-gem"
end
```

## Usage

Releasing a gem locally is the most typical process.

``` bash
$ bake gem:release:version:(major|minor|patch) gem:release
```

This will bump the gem version, commit it, build and push the gem, then tag it.

### Automated

Releasing a gem via a automated pipeline is also supported. Locally, create a release branch:

``` bash
$ bake gem:release:branch:(major|minor|patch)
```

This will create a branch, bump the gem version and commit it. You are then responsible for merging this (e.g. using a pull request). Once this is done, to release the gem:

``` bash
$ export RUBYGEMS_HOST=...
$ export GEM_HOST_API_KEY=...

$ bake gem:release
```
