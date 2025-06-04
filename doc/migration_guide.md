# Migration Guide: From Imperative to Declarative Popups

This guide helps you migrate from Flutter's imperative popup APIs to declarative alternatives provided by `flutter_declarative_popups`.

## Table of Contents
- [Why Migrate?](#why-migrate)
- [Material Design Migrations](#material-design-migrations)
- [Cupertino (iOS) Migrations](#cupertino-ios-migrations)
- [Advanced Patterns](#advanced-patterns)
- [Best Practices](#best-practices)

## Why Migrate?

### Benefits of Declarative Popups

1. **Navigator 2.0 Compatibility**: Full support for declarative navigation
2. **State Management**: Popups become part of your app's navigation state
3. **Deep Linking**: Popups can be part of deep link URLs
4. **State Restoration**: Automatic state restoration for popups
5. **Type Safety**: Better type safety with page-based navigation
6. **Testing**: Easier to test with predictable navigation state

### When to Use Declarative Popups

- When using Navigator 2.0 or go_router
- When popups are part of your navigation flow
- When you need state restoration
- When deep linking to popups
- When testing complex navigation scenarios

## Material Design Migrations

### showDialog → DialogPage

#### Before (Imperative)
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Confirm'),
            content: Text('Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('OK'),
              ),
            ],
          ),
        );
        
        if (result == true) {
          // Handle confirmation
        }
      },
      child: Text('Show Dialog'),
    );
  }
}
```

#### After (Declarative)
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool _showConfirmDialog = false;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
          child: ElevatedButton(
            onPressed: () => setState(() => _showConfirmDialog = true),
            child: Text('Show Dialog'),
          ),
        ),
        if (_showConfirmDialog)
          DialogPage<bool>(
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Confirm'),
              content: Text('Are you sure?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('OK'),
                ),
              ],
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        
        setState(() => _showConfirmDialog = false);
        
        if (result == true) {
          // Handle confirmation
        }
        
        return true;
      },
    );
  }
}
```

### showModalBottomSheet → ModalBottomSheetPage

#### Before (Imperative)
```dart
void _showOptions(BuildContext context) async {
  final option = await showModalBottomSheet<String>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () => Navigator.pop(context, 'share'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ],
      ),
    ),
  );
  
  switch (option) {
    case 'share':
      // Handle share
      break;
    case 'edit':
      // Handle edit
      break;
    case 'delete':
      // Handle delete
      break;
  }
}
```

#### After (Declarative)
```dart
enum BottomSheetAction { none, options }

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  BottomSheetAction _currentSheet = BottomSheetAction.none;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _currentSheet = BottomSheetAction.options);
                },
                child: Text('Show Options'),
              ),
            ),
          ),
        ),
        if (_currentSheet == BottomSheetAction.options)
          ModalBottomSheetPage<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    onTap: () => Navigator.pop(context, 'share'),
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    onTap: () => Navigator.pop(context, 'edit'),
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () => Navigator.pop(context, 'delete'),
                  ),
                ],
              ),
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        
        setState(() => _currentSheet = BottomSheetAction.none);
        
        switch (result) {
          case 'share':
            // Handle share
            break;
          case 'edit':
            // Handle edit
            break;
          case 'delete':
            // Handle delete
            break;
        }
        
        return true;
      },
    );
  }
}
```

## Cupertino (iOS) Migrations

### showCupertinoModalPopup → CupertinoModalPopupPage

#### Before (Imperative)
```dart
void _showActionSheet(BuildContext context) {
  showCupertinoModalPopup<String>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text('Select Photo'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, 'camera'),
          child: Text('Take Photo'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context, 'gallery'),
          child: Text('Choose from Gallery'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
    ),
  ).then((value) {
    if (value == 'camera') {
      // Open camera
    } else if (value == 'gallery') {
      // Open gallery
    }
  });
}
```

#### After (Declarative)
```dart
class PhotoSelector extends StatefulWidget {
  @override
  State<PhotoSelector> createState() => _PhotoSelectorState();
}

class _PhotoSelectorState extends State<PhotoSelector> {
  bool _showPhotoOptions = false;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        CupertinoPage(
          child: CupertinoButton(
            onPressed: () => setState(() => _showPhotoOptions = true),
            child: Text('Select Photo'),
          ),
        ),
        if (_showPhotoOptions)
          CupertinoModalPopupPage<String>(
            builder: (context) => CupertinoActionSheet(
              title: Text('Select Photo'),
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context, 'camera'),
                  child: Text('Take Photo'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context, 'gallery'),
                  child: Text('Choose from Gallery'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        
        setState(() => _showPhotoOptions = false);
        
        if (result == 'camera') {
          // Open camera
        } else if (result == 'gallery') {
          // Open gallery
        }
        
        return true;
      },
    );
  }
}
```

## Advanced Patterns

### With go_router

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
      routes: [
        GoRoute(
          path: 'confirm',
          pageBuilder: (context, state) => DialogPage(
            builder: (context) => ConfirmDialog(
              message: state.queryParams['message'] ?? 'Are you sure?',
            ),
          ),
        ),
        GoRoute(
          path: 'options',
          pageBuilder: (context, state) => ModalBottomSheetPage(
            builder: (context) => OptionsSheet(),
          ),
        ),
      ],
    ),
  ],
);

// Navigate to dialog
context.go('/confirm?message=Delete%20this%20item?');

// Navigate to bottom sheet
context.go('/options');
```

### State Restoration

```dart
class RestoredDialog extends StatefulWidget {
  @override
  State<RestoredDialog> createState() => _RestoredDialogState();
}

class _RestoredDialogState extends State<RestoredDialog> with RestorationMixin {
  final RestorableBool _showDialog = RestorableBool(false);

  @override
  String? get restorationId => 'dialog_example';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_showDialog, 'show_dialog');
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(child: MyContent()),
        if (_showDialog.value)
          DialogPage(
            restorationId: 'my_dialog',
            builder: (context) => MyDialog(),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        _showDialog.value = false;
        return true;
      },
    );
  }

  @override
  void dispose() {
    _showDialog.dispose();
    super.dispose();
  }
}
```

## Best Practices

### 1. Use Enums for Popup State

```dart
enum ActivePopup {
  none,
  deleteConfirm,
  shareOptions,
  userProfile,
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ActivePopup _activePopup = ActivePopup.none;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(child: MainScreen()),
        if (_activePopup == ActivePopup.deleteConfirm)
          DialogPage(builder: (context) => DeleteConfirmDialog()),
        if (_activePopup == ActivePopup.shareOptions)
          ModalBottomSheetPage(builder: (context) => ShareSheet()),
        if (_activePopup == ActivePopup.userProfile)
          CupertinoSheetPage(builder: (context) => UserProfileSheet()),
      ],
      onPopPage: _handlePopPage,
    );
  }

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) return false;
    setState(() => _activePopup = ActivePopup.none);
    // Handle result based on route type
    return true;
  }
}
```

### 2. Create Reusable Popup Widgets

```dart
class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  const ConfirmActionDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  }) : super(key: key);

  static DialogPage<bool> page({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return DialogPage<bool>(
      builder: (context) => ConfirmActionDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// Usage
if (_showDeleteConfirm)
  ConfirmActionDialog.page(
    title: 'Delete Item',
    message: 'This action cannot be undone.',
    confirmText: 'Delete',
  ),
```

### 3. Handle Complex Navigation Flows

```dart
class MultiStepFlow extends StatefulWidget {
  @override
  State<MultiStepFlow> createState() => _MultiStepFlowState();
}

class _MultiStepFlowState extends State<MultiStepFlow> {
  final List<Page> _pages = [];

  void _pushStep(Widget step) {
    setState(() {
      _pages.add(MaterialPage(child: step));
    });
  }

  void _popStep() {
    setState(() {
      if (_pages.isNotEmpty) {
        _pages.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSheetPage(
      useNestedNavigation: true,
      builder: (context) => Navigator(
        pages: [
          MaterialPage(child: Step1(onNext: () => _pushStep(Step2()))),
          ..._pages,
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          _popStep();
          return true;
        },
      ),
    );
  }
}
```

### 4. Testing Declarative Popups

```dart
testWidgets('dialog flow test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Navigator(
        pages: [
          MaterialPage(child: HomeScreen()),
          DialogPage(
            builder: (context) => ConfirmDialog(),
          ),
        ],
        onPopPage: (route, result) => route.didPop(result),
      ),
    ),
  );

  // Dialog should be visible
  expect(find.text('Confirm'), findsOneWidget);

  // Interact with dialog
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Dialog should be dismissed
  expect(find.text('Confirm'), findsNothing);
});
```

## Summary

Migrating to declarative popups provides better integration with modern Flutter navigation patterns. While it requires a different mental model, the benefits in terms of state management, testing, and deep linking make it worthwhile for apps using Navigator 2.0 or similar declarative navigation systems.

Key points to remember:
- Popups become part of your navigation state
- Use enums or similar patterns to track active popups
- Handle results in `onPopPage` callback
- Create reusable popup page widgets
- Test popups as part of your navigation flow
