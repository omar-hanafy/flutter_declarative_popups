#!/bin/bash

# Release script for Flutter Declarative Popups
# Usage: ./release.sh [major|minor|patch]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the release type
RELEASE_TYPE=$1

if [ -z "$RELEASE_TYPE" ]; then
    echo -e "${RED}Error: Please specify release type (major|minor|patch)${NC}"
    echo "Usage: ./release.sh [major|minor|patch]"
    exit 1
fi

if [[ ! "$RELEASE_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: Invalid release type. Use major, minor, or patch${NC}"
    exit 1
fi

echo -e "${GREEN}Starting $RELEASE_TYPE release...${NC}"

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: Working directory is not clean. Commit or stash changes first.${NC}"
    exit 1
fi

# Make sure we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${RED}Error: Not on main branch. Switch to main branch first.${NC}"
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
echo -e "Current version: ${YELLOW}$CURRENT_VERSION${NC}"

# Calculate new version
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

case $RELEASE_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo -e "New version: ${GREEN}$NEW_VERSION${NC}"

# Update version in pubspec.yaml
echo "Updating pubspec.yaml..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
fi

# Update CHANGELOG.md
echo "Updating CHANGELOG.md..."
TODAY=$(date +%Y-%m-%d)
CHANGELOG_ENTRY="## [$NEW_VERSION] - $TODAY"

# Create a temporary file with the new entry
echo -e "$CHANGELOG_ENTRY\n" > temp_changelog.md
echo -e "### Added\n- \n" >> temp_changelog.md
echo -e "### Changed\n- \n" >> temp_changelog.md
echo -e "### Fixed\n- \n" >> temp_changelog.md
echo "" >> temp_changelog.md

# Append the rest of the changelog
cat CHANGELOG.md >> temp_changelog.md
mv temp_changelog.md CHANGELOG.md

echo -e "${YELLOW}Please update CHANGELOG.md with your changes${NC}"
echo "Opening CHANGELOG.md in default editor..."

# Open in default editor
if command -v code &> /dev/null; then
    code CHANGELOG.md
elif command -v nano &> /dev/null; then
    nano CHANGELOG.md
else
    vi CHANGELOG.md
fi

# Wait for user confirmation
echo -e "${YELLOW}Press Enter when you've finished updating CHANGELOG.md...${NC}"
read -r

# Run tests
echo "Running tests..."
flutter test

# Check publish readiness
echo "Checking publish readiness..."
flutter pub publish --dry-run

# Commit changes
echo "Committing changes..."
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to $NEW_VERSION"

# Create and push tag
TAG="flutter_declarative_popups-v$NEW_VERSION"
echo -e "Creating tag: ${GREEN}$TAG${NC}"
git tag -a "$TAG" -m "Release version $NEW_VERSION"

# Push changes and tag
echo "Pushing changes and tag..."
git push origin main
git push origin "$TAG"

echo -e "${GREEN}✅ Release $NEW_VERSION completed!${NC}"
echo -e "${GREEN}GitHub Actions will now automatically publish to pub.dev${NC}"
echo ""
echo "Next steps:"
echo "1. Check GitHub Actions for the publish workflow"
echo "2. Verify the package on pub.dev"
echo "3. Check the GitHub release page"
