# Releases

## v0.4.0

  - Add agent context.

## v0.3.1

  - Modernize gem structure and dependencies.

## v0.3.0

    - Add `expect_console` helper method for more fluent test assertions.
    - Add `have_logged` predicate for checking logged messages with specific fields.

## v0.2.0

  - Avoid using nested fiber to prevent potential issues with fiber-based concurrency.

## v0.1.0

    - Add `Sus::Fixtures::Console::CapturedLogger` for capturing console output during tests.
    - Add `Sus::Fixtures::Console::NullLogger` for suppressing console output during tests.
