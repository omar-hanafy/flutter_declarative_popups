# Contributing to Flutter Declarative Popups

Thank you for considering contributing to Flutter Declarative Popups! This document outlines the process for contributing to this project.

## 🚀 Getting Started

Use Flutter 3.47.7 or newer with Dart 3.13.5 or newer.

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_declarative_popups.git
   cd flutter_declarative_popups
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/omar-hanafy/flutter_declarative_popups.git
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

## 🔄 Development Workflow

### 1. Create a New Branch

Always create a new branch for your work:

```bash
git checkout -b feat/my-new-feature
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feat/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or fixes
- `ci/` - CI/CD changes

### 2. Make Your Changes

- Write clean, documented code
- Follow the existing code style
- Add tests for new functionality
- Update documentation as needed
- Update CHANGELOG.md with your changes

### 3. Commit Your Changes

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat: add new awesome feature"
git commit -m "fix: resolve issue with dialog dismissal"
git commit -m "docs: update README with new examples"
```

### 4. Run Tests and Checks

Before pushing, ensure all tests pass:

```bash
# Check formatting
dart format --output=none --set-exit-if-changed .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run navigation flows in the macOS example app
cd example
flutter test integration_test -d macos
cd ..

# Check publish readiness
dart pub publish --dry-run

# Require the full Pana score
dart pub global activate pana 0.23.19
dart pub global run pana --exit-code-threshold 0 .
```

### 5. Push and Create Pull Request

```bash
git push origin feat/my-new-feature
```

Then create a Pull Request on GitHub.

## 📋 Pull Request Requirements

### PR Title
Must follow conventional commits format:
- `feat: description` - New features
- `fix: description` - Bug fixes
- `docs: description` - Documentation
- `refactor: description` - Code refactoring
- `test: description` - Tests
- `ci: description` - CI/CD changes

### PR Description
Include:
- **What**: Brief description of changes
- **Why**: Reason for the changes
- **How**: Technical approach taken
- **Testing**: How you tested the changes
- **Breaking Changes**: Note any breaking changes

### Checklist
- [ ] Code follows the project style guidelines
- [ ] Tests added/updated for new functionality
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated
- [ ] Version bumped in pubspec.yaml (if applicable)
- [ ] All tests passing
- [ ] No analyzer warnings

## 🏷️ Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Breaking changes
- **MINOR** (0.X.0): New features (backwards compatible)
- **PATCH** (0.0.X): Bug fixes (backwards compatible)

### When to Bump Version

1. **Bug fixes**: Increment patch version (0.1.0 → 0.1.1)
2. **New features**: Increment minor version (0.1.1 → 0.2.0)
3. **Breaking changes**: Increment major version (0.2.0 → 1.0.0)

Update version in:
- `pubspec.yaml`
- `CHANGELOG.md` (add entry for new version)

## 🚦 CI/CD Process

### Pull Request Checks

CI checks formatting, static analysis, and tests on the latest stable Flutter
SDK. It also analyzes and tests the lowest allowed dependency versions on
Flutter 3.47.7. Beta checks are advisory. Pana requires the full score, and the
publication dry-run must pass without warnings.

PRs targeting `main` must contain a stable version. PRs targeting `dev` must
contain a prerelease version, such as `1.1.0-dev.1`. These lane checks apply even
when the PR does not change `pubspec.yaml`.

### Releases

Prepare the version and changelog on a working branch and open a PR into the
appropriate release lane. A merged version change creates the immutable tag
`flutter_declarative_popups-v<version>` and a GitHub release. The tag push triggers
publication through pub.dev Trusted Publisher OIDC. GitHub release notes use
the matching changelog section and must not contain user or team mentions.

Use `bash scripts/release.sh main` or `bash scripts/release.sh dev` for the local
preflight. Release tags are created by the reviewed auto-release workflow.
See [SETUP.md](SETUP.md) for repository configuration and release monitoring.

## 📝 Code Style Guidelines

- Use `flutter_lints` package rules
- Maximum line length: 80 characters (relaxed for URLs)
- Use meaningful variable and function names
- Add dartdoc comments for public APIs
- Prefer single quotes for strings
- Use trailing commas for better formatting

## 🧪 Testing Guidelines

- Write tests for all new features
- Maintain >90% code coverage
- Test both happy paths and edge cases
- Use descriptive test names
- Group related tests

Example:
```dart
group('DialogPage', () {
  testWidgets('should show dialog with correct title', (tester) async {
    // Test implementation
  });

  testWidgets('should return result when dismissed', (tester) async {
    // Test implementation
  });
});
```

## 🤝 Code Review Process

1. Follow the target branch's configured review requirements
2. Address all review comments
3. Keep discussions professional and constructive
4. Be open to feedback and suggestions

## 📚 Additional Resources

- [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

## ❓ Questions?

If you have questions, feel free to:
- Open an issue for discussion
- Ask in the PR comments
- Contact the maintainers

Thank you for contributing! 🎉
