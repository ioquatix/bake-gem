# Bake::Gem

Provides bake tasks for common gem release workflows.

[![Development Status](https://github.com/ioquatix/bake-gem/workflows/Development/badge.svg)](https://github.com/ioquatix/bake-gem/actions?workflow=Development)

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

## License

Released under the MIT license.

Copyright, 2020, by [Samuel G. D. Williams](http://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
