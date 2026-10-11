#!/usr/bin/env bash
set -euo pipefail

lane=${1:-}
version=$(awk '/^version:/ {print $2; exit}' pubspec.yaml | tr -d "\"'")
stable_pattern='^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9A-Za-z.-]+)?$'
prerelease_pattern='^[0-9]+\.[0-9]+\.[0-9]+-[0-9A-Za-z.-]+(\+[0-9A-Za-z.-]+)?$'

case "$lane" in
  main)
    if [[ ! "$version" =~ $stable_pattern ]]; then
      echo "main requires a stable semantic version, got $version." >&2
      exit 1
    fi
    ;;
  dev)
    if [[ ! "$version" =~ $prerelease_pattern ]]; then
      echo "dev requires a prerelease semantic version, got $version." >&2
      exit 1
    fi
    ;;
  *)
    echo 'Usage: bash scripts/check-version-lane.sh main|dev' >&2
    exit 1
    ;;
esac

echo "Version $version is valid for $lane."
