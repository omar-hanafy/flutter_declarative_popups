# Contributing to Flutter Declarative Popups

First off, thank you for considering contributing to Flutter Declarative Popups! It's people like you that make this package better for everyone.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots if possible**
- **Include your Flutter version** (`flutter --version`)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Provide specific examples to demonstrate the enhancement**
- **Describe the current behavior and explain the expected behavior**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes (`flutter test`)
5. Make sure your code follows the existing style (`flutter analyze`)
6. Write a good commit message

## Development Process

1. **Set up your development environment**
   ```bash
   git clone https://github.com/yourusername/flutter_declarative_popups.git
   cd flutter_declarative_popups
   flutter pub get
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Run the example app**
   ```bash
   cd example
   flutter run
   ```

4. **Check code quality**
   ```bash
   flutter analyze
   dart format --set-exit-if-changed .
   ```

## Style Guide

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep methods small and focused
- Write tests for new features

## Adding New Popup Types

When adding a new popup type:

1. Create the page class in the appropriate folder (`lib/src/material/`, `lib/src/cupertino/`, or `lib/src/raw/`)
2. Add comprehensive documentation with examples
3. Export it from `lib/flutter_declarative_popups.dart`
4. Add extension methods in `lib/src/utils/extensions.dart`
5. Add tests in the `test/` directory
6. Add examples to the example app
7. Update the README with the new popup type

## Testing

- Write unit tests for all new functionality
- Ensure all existing tests pass
- Test on both iOS and Android
- Test with different Flutter versions if possible

## Documentation

- Add dartdoc comments to all public APIs
- Include code examples in documentation
- Update the README for significant changes
- Update the CHANGELOG.md

## Questions?

Feel free to open an issue with the `question` label if you have any questions about contributing.

Thank you for contributing! 🎉
