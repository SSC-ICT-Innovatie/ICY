#!/bin/bash
cd "$(dirname "$0")/.."

# Generate mock files first
echo "Generating mock files..."
dart run build_runner build --delete-conflicting-outputs

# Run the tests
echo "Running tests..."
flutter test "$@"

# If you want to run with coverage, use:
# flutter test --coverage
