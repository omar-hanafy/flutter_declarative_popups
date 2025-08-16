# Flutter Declarative Popups - Routing Examples

This example demonstrates how to use `flutter_declarative_popups` with different routing approaches in Flutter.

## Features

The example includes implementations for:

1. **Navigator 2.0** (Default) - Direct implementation using RouterDelegate and RouteInformationParser
2. **Navigator 1.0** - Classic imperative navigation
3. **go_router** - Official declarative routing package
4. **auto_route** - Code generation based routing

## Running the Example

1. First, get the dependencies:
```bash
flutter pub get
```

2. For auto_route, you need to run the code generator:
```bash
dart run build_runner build
```

3. Run the app:
```bash
flutter run
```

## Switching Between Routing Implementations

Use the dropdown in the top-right corner of the app to switch between different routing implementations. The default is Navigator 2.0.

## Implementation Details

### Navigator 2.0
- Direct implementation of `RouterDelegate` and `RouteInformationParser`
- Full control over the navigation stack
- Each popup has its own path (e.g., `/dialog`, `/bottom-sheet`)

### Navigator 1.0
- Shows both traditional imperative navigation and declarative pages
- Uses `Navigator.push()` with popup pages
- Note: Path-based navigation is not available

### go_router
- Each popup is defined as a route with its own path
- Supports deep linking and browser history
- Uses `context.push()` for navigation

### auto_route
- Requires code generation (`@RoutePage()` annotation)
- Type-safe navigation with generated route classes
- Note: auto_route doesn't natively support declarative popup pages as overlays
- This example demonstrates using imperative popups alongside auto_route's routing

## Popup Types Demonstrated

- **DialogPage** - Material Design dialogs
- **ModalBottomSheetPage** - Bottom sheets with drag handle
- **CupertinoDialogPage** - iOS-style dialogs

All popups support returning results to the calling page.
