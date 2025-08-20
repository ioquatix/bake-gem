# Bake::Gem

Provides bake tasks for common gem release workflows.

[![Development Status](https://github.com/ioquatix/bake-gem/workflows/Test/badge.svg)](https://github.com/ioquatix/bake-gem/actions?workflow=Test)

## Usage

Please see the [project documentation](https://ioquatix.github.io/bake-gem/) for more details.

  - [Getting Started](https://ioquatix.github.io/bake-gem/guides/getting-started/index) - This guide explains how to use `bake-gem` to release gems safely and efficiently.

## Releases

Please see the [project releases](https://ioquatix.github.io/bake-gem/releases/index) for all releases.

### v0.12.0

  - Add `guard_last_commit_not_version_bump` method to prevent consecutive version bumps.
  - Add `build_gem_in_worktree` method for building gems in isolated git worktrees.
  - Improve shell command execution with better error handling and specific exit code access.

### v0.11.1

  - Better integration with `bake`'s default output.

### v0.11.0

  - Improved bake task return values.

### v0.10.0

  - Better handling of versions.

### v0.9.0

  - Add `after_gem_release_version_increment` hook.

## See Also

  - [Bake](https://github.com/ioquatix/bake) — The bake task execution tool.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
