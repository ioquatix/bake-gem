# Getting Started

This guide explains how to use `bake-gem` to release gems safely and efficiently.

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

Before using `bake-gem`, ensure you have:

1. A properly configured `gemspec` file in your project root
2. A clean git repository (no uncommitted changes)
3. Your gem's version file (typically `lib/your_gem/version.rb`)
4. RubyGems credentials configured for publishing

### Local Release Process

The most typical process for releasing a gem locally:

``` bash
$ bake gem:release:patch
```

This single command will:
1. **Guard against consecutive version bumps** - Prevents accidentally bumping version twice
2. **Check repository cleanliness** - Ensures no uncommitted changes
3. **Increment the patch version** - Updates your version file (e.g., 1.0.0 → 1.0.1)
4. **Commit the version change** - Creates a commit with the version bump
5. **Build the gem in a clean worktree** - Isolates the build process
6. **Push to RubyGems** - Publishes your gem
7. **Create and push git tags** - Tags the release

### Version Increment Options

Choose the appropriate version increment for a complete release:

``` bash
# For bug fixes (1.0.0 -> 1.0.1)
$ bake gem:release:patch

# For new features (1.0.0 -> 1.1.0)
$ bake gem:release:minor

# For breaking changes (1.0.0 -> 2.0.0)
$ bake gem:release:major
```

For more control, you can also use the traditional two-step process:

``` bash
# Step 1: Bump version and commit
$ bake gem:release:version:patch  # or minor/major

# Step 2: Build and release
$ bake gem:release
```

## Advanced Workflows

### Automated CI/CD Pipeline

For releasing gems via automated pipelines, use a two-step process:

#### Step 1: Create Release Branch (Locally)

``` bash
# Create a release branch with version bump
$ bake gem:release:branch:patch  # or minor/major
```

This will:
- Create a new branch named `releases/v[new-version]`
- Bump the gem version
- Commit the version change
- Push the branch to origin

#### Step 2: Release from CI (After Merge)

Once the release branch is merged into main:

``` bash
$ export RUBYGEMS_HOST=https://rubygems.org
$ export GEM_HOST_API_KEY=your_api_key

$ bake gem:release
```

### Individual Commands

You can also run individual steps:

``` bash
# Just build the gem
$ bake gem:build

# Install the gem locally for testing
$ bake gem:install

# List files that will be included in the gem
$ bake gem:files

# Build without signing
$ bake gem:build signing_key=false
```

## Safety Features

`bake-gem` includes several safety features:

### Consecutive Version Bump Prevention
The tool automatically prevents consecutive version bumps by checking the last commit message. If the last commit was already a version bump (e.g., "Bump patch version."), it will raise an error.

### Clean Worktree Building
Gems are built in isolated git worktrees to ensure the build environment exactly matches your committed code, preventing issues with uncommitted changes affecting the build.

### Repository Cleanliness Check
Before any release operation, the tool ensures your repository has no uncommitted changes.

## Configuration

### Gem Signing

To sign your gems, ensure your gemspec includes:

``` ruby
spec.signing_key = "path/to/private_key.pem"
spec.cert_chain = ["path/to/certificate.pem"]
```

Or disable signing explicitly:

``` bash
$ bake gem:build signing_key=false
```

### RubyGems Configuration

For automated releases, set these environment variables:

``` bash
export RUBYGEMS_HOST=https://rubygems.org  # or your private gem server
export GEM_HOST_API_KEY=your_api_key
```

## Examples

### Complete Release Example

``` bash
# 1. Ensure clean repository
$ git status

# 2. Run tests
$ bundle exec rake test  # or your test command

# 3. Release with patch version increment (single command)
$ bake gem:release:patch

# Output:
# Updated version: v1.2.4
# Successfully built RubyGem
# Name: my-gem
# Version: 1.2.4
# File: my-gem-1.2.4.gem
# Pushing gem to https://rubygems.org...
# Tagged: v1.2.4
```

### Branch-based Release Example

``` bash
# Create release branch
$ bake gem:release:branch:minor
# Creates branch: releases/v1.3.0
# Commits version bump
# Pushes branch

# After code review and merge:
$ git checkout main
$ git pull
$ bake gem:release
```
