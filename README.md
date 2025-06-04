# Flutter Declarative Popups

A modern, declarative approach to handling popups in Flutter using Navigator 2.0. Simplify your navigation logic,
enhance readability, and easily manage state restoration with page-based alternatives to Flutter's imperative popup
APIs.

## Features
* **Declarative Popups**: Seamless integration with Flutter's Navigator 2.0 and GoRouter.
* **Multiple Popup Types**: Supports Material and Cupertino dialogs, sheets, and bottom sheets.
* **Customizable Barrier**: Full control over barrier behavior, including dismissibility, color, and tap handling.
* **Convenient Extensions**: Easy-to-use methods to create and push popup pages.
* **State Restoration**: Easily restore popup states through Flutter's built-in mechanisms.

## Installation

```yaml
dependencies:
  flutter_declarative_popups: ^0.1.0
```

```dart
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
```

---

## Quick start

### 1. push imperatively—with the **extensions**

```dart
// From any BuildContext
await context.showDeclarativeDialog<bool>(
  builder: (_) => AlertDialog(
    title: const Text('Delete item?'),
    content: const Text('This action cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(_, true),  child: const Text('Delete')),
    ],
  ),
);
```

### 2. Or Add a popup page to `Navigator.pages`

```dart
Navigator(
  pages: [
    const MaterialPage(child: HomeScreen()),
    if (showDialog)
      DialogPage<void>(
        key: const ValueKey('confirm-delete'),
        builder: (context) => const _ConfirmDeleteDialog(),
      ),
  ],
  onPopPage: (route, result) {
    if (!route.didPop(result)) return false;
    setState(() => showDialog = false);
    return true;
  },
);
```

---

## API snippets

### DialogPage

```dart
await context.showDeclarativeDialog<bool>(
  builder: (_) => AlertDialog(
    title: const Text('Delete item?'),
    content: const Text('This action cannot be undone.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancel')),
      TextButton(onPressed: () => Navigator.pop(_, true),  child: const Text('Delete')),
    ],
  ),
);
```

### ModalBottomSheetPage

```dart
await context.showDeclarativeModalBottomSheet<void>(
  builder: (_) => const _SettingsSheet(),
  showDragHandle: true,
  isScrollControlled: true,
);
```

### CupertinoModalPopupPage

```dart
await context.pushCupertinoModalPopup<String>(
  builder: (_) => CupertinoActionSheet(
    title: const Text('Photo options'),
    actions: [
      CupertinoActionSheetAction(
        child: const Text('Delete'),
        isDestructiveAction: true,
        onPressed: () => Navigator.pop(_, 'delete'),
      ),
      CupertinoActionSheetAction(
        child: const Text('Share'),
        onPressed: () => Navigator.pop(_, 'share'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      child: const Text('Cancel'),
      onPressed: () => Navigator.pop(_, null),
    ),
  ),
);
```

### CupertinoSheetPage (with nested navigation)

```dart
await context.showCupertinoSheet<void>(
  builder: (_) => const EditProfileFlow(),
  useNestedNavigation: true,
  showDragHandle: true,
);
```

### RawDialogPage

```dart
await context.showRawDialog<void>(
  pageBuilder: (context, animation, _) => FadeTransition(
    opacity: animation,
    child: const Center(child: _MyCustomDialog()),
  ),
);
```


## Using with `go_router`

A minimalist setup that shows a dialog when the `/confirmExit` route is hit:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'confirmExit',
          pageBuilder: (context, state) => DialogPage<void>(
            key: state.pageKey,
            builder: (_) => const _ConfirmDeleteDialog(),
          ),
        ),
      ],
    ),
  ],
);

// Trigger the dialog from anywhere in your app:
context.go('/confirmExit');
```

You can swap `DialogPage` for `ModalBottomSheetPage`, `CupertinoModalPopupPage`, or any other popup page—the pattern stays identical.
---


## Supported Popups

* Cupertino (iOS-style)
    * **CupertinoModalPopupPage**: Presents modal popups (e.g., action sheets).
    * **CupertinoSheetPage**: Displays content as draggable sheets with iOS styling.
* Material Design
    * **DialogPage**: Displays Material Design dialogs declaratively.
    * **ModalBottomSheetPage**: Presents Material modal bottom sheets.
* Custom/Raw Dialogs
    * **RawDialogPage**: For complete control over dialog content and animations.

## Customization

All popup types offer comprehensive customization including:

* Barrier appearance and behavior
* Animation control
* Focus handling
* SafeArea integration

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This project is licensed under the BSD 3-Clause License. See the LICENSE file for details.
