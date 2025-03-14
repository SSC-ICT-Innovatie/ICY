# ICY Tests

## Set Up Testing Environment

Before running tests, you need to install the dependencies and generate the mock files:

```bash
# Install dependencies
flutter pub get

# Generate mock files
dart run build_runner build --delete-conflicting-outputs
```

## Running Tests

You can run the tests using the following commands:

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/auth/auth_repository_test.dart

# Run tests with coverage
flutter test --coverage
```

## Testing Structure

- `test/auth/` - Tests for authentication features
- `test/notifications/` - Tests for notification features
- `test/widgets/` - Tests for widgets

## Mocking

We use Mockito for mocking in tests. The mock files are generated automatically using build_runner.

If you add new tests that require mocks, you may need to update the `build.yaml` file to include the new test files.
