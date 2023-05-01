# Bake::Gem

Provides bake tasks for common gem release workflows.

[![Test](https://github.com/ioquatix/bake-gem/workflows/Test/badge.svg)](https://github.com/ioquatix/bake-gem/actions?workflow=Test)

## Installation

``` shell
$ bundle add bake-gem
```

## Usage

### Local

Releasing a gem locally is the most typical process.

``` shell
$ bake gem:release:version:(major|minor|patch) gem:release
```

This will bump the gem version, commit it, build and push the gem, then tag it.

### Automated

Releasing a gem via a automated pipeline is also supported. Locally, create a release branch:

``` shell
$ bake gem:release:branch:(major|minor|patch)
```

This will create a branch, bump the gem version and commit it. You are then responsible for merging this into master (e.g. using a pull request). Once this is done, to automatically release the gem:

``` shell
$ export RUBYGEMS_HOST=...
$ export GEM_HOST_API_KEY=...

$ bake gem:release
```

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request

## See Also

  - [Bake](https://github.com/ioquatix/bake) — The bake task execution tool.
