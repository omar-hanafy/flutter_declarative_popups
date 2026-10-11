# Migrating to declarative popups

Version 2.0.0 requires Flutter 3.47.7 and Dart 3.13.5 or newer.

Popup pages belong in `Navigator.pages` or a router's page builder. The application
owns the page list; a popup's dismissal must remove its page from that list.

## Choose a page

| Imperative API | Declarative page |
| --- | --- |
| `showDialog` | `DialogPage<T>` |
| `showModalBottomSheet` | `ModalBottomSheetPage<T>` |
| `showCupertinoDialog` | `CupertinoDialogPage<T>` |
| `showCupertinoModalPopup` | `CupertinoModalPopupPage<T>` |
| `showCupertinoSheet` | `CupertinoSheetPage<T>` |
| `showGeneralDialog` | `RawDialogPage<T>` |

For classic navigation, a page can also create a route:

```dart
final result = await Navigator.of(context).push<bool>(
  DialogPage<bool>(builder: (_) => const ConfirmDialog()).createRoute(context),
);
if (!context.mounted) return;
// Use result or update the UI.
```

The runnable examples live in [`example/lib`](../example/lib).

## Migrate result handling and page removal

Use `Page.onPopInvoked` for typed results and `Navigator.onDidRemovePage` to update
the page list. `onDidRemovePage` does not receive a result. Keep these responsibilities
independent instead of assuming the callbacks run in a particular order.

```dart
class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  static const _dialogKey = ValueKey('confirm');
  bool _showDialog = false;
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: <Page<void>>[
        MaterialPage<void>(
          key: const ValueKey('home'),
          child: Scaffold(
            body: Column(
              children: [
                Text(_lastResult ?? 'No result'),
                ElevatedButton(
                  onPressed: () => setState(() => _showDialog = true),
                  child: const Text('Open dialog'),
                ),
              ],
            ),
          ),
        ),
        if (_showDialog)
          DialogPage<bool>(
            key: _dialogKey,
            onPopInvoked: (didPop, result) {
              if (didPop && mounted) {
                setState(() {
                  _lastResult = result == true ? 'Confirmed' : 'Cancelled';
                });
              }
            },
            builder: (dialogContext) => AlertDialog(
              title: const Text('Confirm action'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
      ],
      onDidRemovePage: (page) {
        if (page.key == _dialogKey && mounted) {
          setState(() => _showDialog = false);
        }
      },
    );
  }
}
```

Use the same pattern for bottom sheets and Cupertino popups. For example, a
`ModalBottomSheetPage<String>` can return an action such as `'share'` through its
`onPopInvoked` callback.

## Block user dismissal

Set `canPop: false` on the page, or wrap its content in `PopScope<T>` when the
content owns the guard. `onPopInvoked` reports whether an attempted pop succeeded.
For guarded programmatic dismissal, call `Navigator.maybePop`. An explicit
`Navigator.pop` is a command to pop and does not consult those guards.

```dart
DialogPage<bool>(
  key: const ValueKey('unsaved-changes'),
  canPop: !hasUnsavedChanges,
  onPopInvoked: (didPop, result) {
    if (!didPop) {
      // Explain why dismissal is blocked.
    }
  },
  builder: (_) => const EditDialog(),
)
```

Custom `onBarrierTap` callbacks replace the normal dismissal action. If the
callback should close the popup, call `Navigator.maybePop` on its owning navigator.
A non-dismissible barrier does not call the callback.

## Update an existing popup

Use a stable key to retain a route and its state. Rebuilding the page updates its
builder and supported options from the new page configuration.

```dart
DialogPage<void>(
  key: const ValueKey('status-dialog'),
  barrierDismissible: !isSaving,
  builder: (_) => StatusDialog(message: statusMessage),
)
```

Use a different key to intentionally replace the popup. Some lifecycle options
are fixed by Flutter's route implementation; consult the page's API documentation
for options that require replacement.

## go_router

Keep the router alive for the lifetime of its owning widget and dispose it when
that widget is removed. Use the route state's page key for popup identity.

```dart
GoRoute(
  path: 'confirm',
  pageBuilder: (context, state) => DialogPage<bool>(
    key: state.pageKey,
    builder: (_) => ConfirmDialog(
      message: state.uri.queryParameters['message'] ?? 'Continue?',
    ),
  ),
)
```

Use `context.push<bool>('/confirm')` to await a result. Check `mounted` before
updating a widget after the await. Use `go` when the intent is to replace the
configured location instead of waiting for a popup result.

## Cupertino scrollable sheets and nested navigation

Pass Flutter's supplied controller to the primary scrollable so scrolling and
dragging cooperate:

```dart
CupertinoSheetPage<String>(
  key: const ValueKey('options-sheet'),
  scrollableBuilder: (context, controller) => CupertinoPageScaffold(
    child: ListView.builder(
      controller: controller,
      itemCount: 20,
      itemBuilder: (context, index) => CupertinoListTile(
        title: Text('Option ${index + 1}'),
        onTap: () => Navigator.of(context).pop('option-$index'),
      ),
    ),
  ),
)
```

A sheet's native drag dismisses the navigator that owns its route. The
`useNestedNavigation` option creates an inner navigator for content; a `pop` from
that inner context addresses the inner navigator. To close the sheet from nested
content, retain or explicitly select the navigator that owns the sheet. Flutter's
root-sheet helper targets the root navigator and is appropriate only when the
sheet is actually presented there.

## State restoration

Restoration requires application state as well as route metadata:

1. Configure `restorationScopeId` on the app and navigator.
2. Assign `restorationId` to each page whose route state should be restored.
3. Restore the state that determines the page list, using `RestorationMixin` or
   the router's supported restoration mechanism.
4. Register and dispose restorable properties in their owning widget.

A popup page does not persist the page list by itself. Hot restart is not a test
of process-death restoration; use Flutter's restoration testing tools.

## Earlier versions

For upgrades from 0.3.x, apply the 1.0.0 changes described in the
[changelog](../CHANGELOG.md#100---2026-05-20), including `topGap` in place of
`topGapRatio`, `Page.canPop` in place of `onWillPop`, and page-based Cupertino
popups in place of the removed overlay widgets.
