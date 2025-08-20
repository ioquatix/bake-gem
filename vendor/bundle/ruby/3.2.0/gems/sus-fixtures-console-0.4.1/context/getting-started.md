# Getting Started

This guide explains how to use the `Sus::Fixtures::Console` gem to redirect console logging output during tests.

## Installation

Add the gem to your project:

``` bash
$ bundle add sus-fixtures-console
```

## Core Concepts

`sus-fixtures-console` provides two main fixtures:

- {ruby Sus::Fixtures::Console::CapturedLogger} - Captures console output for inspection and testing.
- {ruby Sus::Fixtures::Console::NullLogger} - Suppresses console output to reduce noise during test runs.

## Usage

### Capturing Console Output

Here is a basic example of a test, that captures the log output:

``` ruby
require 'sus/fixtures/console/captured_logger'

describe Sus::Fixtures::Console::CapturedLogger do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	it "should capture output" do
		Console.debug("Hello, World!")
		
		expect(console_capture.last).to have_keys(
			severity: be == :debug,
			subject: be == "Hello, World!"
		)
	end
end
```

### Ignoring Console Output

If you want to ignore the console output, you can use the `Sus::Fixtures::Console::NullLogger` fixture:

``` ruby
describe Sus::Fixtures::Console::NullLogger do
	include_context Sus::Fixtures::Console::NullLogger
	
	it "should capture output" do
		expect($stderr).not.to receive(:puts)
		expect($stderr).not.to receive(:write)
		
		Console.debug("Hello, World!")
	end
end
```

### Advanced Usage

You can also use the `expect_console` helper method for more fluent test assertions:

``` ruby
describe Sus::Fixtures::Console::CapturedLogger do
	include_context Sus::Fixtures::Console::CapturedLogger
	
	it "can use expect_console helper" do
		Console.info("Processing complete")
		
		expect_console.to have_logged(
			severity: be == :info,
			subject: be == "Processing complete"
		)
	end
end
```

### Setting a Default Log Level

In many cases, you may wish to set a default log level that only prints warnings or above:

``` ruby
# In your `config/sus.rb` file:
require 'console'
Console.logger.warn!
```
