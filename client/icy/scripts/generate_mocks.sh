#!/bin/bash
cd "$(dirname "$0")/.."
echo "Generating mocks..."
dart run build_runner build --delete-conflicting-outputs
echo "Mocks generated."
