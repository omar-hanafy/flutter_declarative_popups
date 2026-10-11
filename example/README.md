# Flutter Declarative Popups examples

Requires Flutter 3.47.7 / Dart 3.13.5 or newer.

```bash
flutter pub get
flutter run
```

Use the menu in the app bar to switch between:

- **Navigator 2.0**: a `RouterDelegate` and `RouteInformationParser` maintain a
  page list, with results handled through `Page.onPopInvoked` and removal through
  `Navigator.onDidRemovePage`.
- **Navigator 1.0**: push a route created by a popup page and await its typed result.
- **go_router 18**: define popup pages with `GoRoute.pageBuilder` and await
  `context.push<String>()`.

The examples demonstrate Material dialogs and bottom sheets, Cupertino dialogs,
and a Cupertino scrollable sheet in the Navigator examples. No code generation
is required.

Run the app integration checks on macOS:

```bash
flutter test integration_test -d macos
```
