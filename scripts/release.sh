#!/usr/bin/env bash
# Local preflight for a release PR. Release tags are created by auto-release.yml.
set -euo pipefail

lane=${1:-}
if [[ "$lane" != main && "$lane" != dev ]]; then
  echo 'Usage: bash scripts/release.sh main|dev' >&2
  exit 1
fi

cd "$(git rev-parse --show-toplevel)"
bash scripts/check-version-lane.sh "$lane"
notes_file=$(mktemp)
trap 'rm -f "$notes_file"' EXIT
version=$(awk '/^version:/ {print $2; exit}' pubspec.yaml | tr -d "\"'")
python3 scripts/release-notes.py "$version" CHANGELOG.md "$notes_file"
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

if [[ -n "$(git status --porcelain)" ]]; then
  echo 'Commit the reviewed release changes before the clean-tree publication checks.' >&2
  exit 1
fi

dart pub publish --dry-run
dart pub global activate pana 0.23.19
dart pub global run pana --exit-code-threshold 0 .

echo "Local preflight passed. Open a release PR targeting $lane and wait for its required checks."
