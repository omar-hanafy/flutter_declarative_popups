# Changelog

## [2.0.0] - 2026-10-11

### Breaking changes

- Raised the minimum SDK requirements to Flutter 3.47.7 and Dart 3.13.5.
- Rebuilding a popup page with the same type and key now updates its content and supported route options while preserving its route and widget state. Use a new key to intentionally replace the popup.

### Additions

- Added `fullscreenDialog` support to Material and raw dialog pages and their extension helpers.
- Added `canPop` and `onPopInvoked` passthroughs to navigation and page-builder extension helpers.

### Fixes

- Fixed custom Material bottom-sheet barrier callbacks so they replace automatic dismissal.
- Fixed Cupertino barriers with custom accessibility hints bypassing pop guards.
- Fixed Material and Cupertino sheet drag dismissal ignoring `Page.canPop` or `PopScope`, including Material drag handles and scroll-to-dismiss signals.
- Fixed nested Cupertino sheets retaining stale content and scroll controllers after page updates.
- Updated Material barrier defaults to follow the dialog and bottom-sheet themes, and resolved Cupertino barrier colors for dark mode.
- Fixed custom Cupertino dialog transition durations being ignored by Flutter's native spring animation.
- Fixed example routing lifecycle and result handling, and updated the example to go_router 18.
- Migrated the example's native projects to the current Flutter setup, including iOS 15, macOS 12, and iOS scene lifecycle support.
- Updated migration examples to use `onDidRemovePage` and typed `onPopInvoked` callbacks, and clarified restoration and nested-sheet navigation requirements.

## [1.0.0] - 2026-05-20

First stable release. The Cupertino sheet implementation has been
rewritten on top of the new Flutter 3.44 `CupertinoSheetRoute` API, and
the public surface has been trimmed before semver locks it in.

### Breaking changes

- Raised the minimum SDK requirements to Flutter 3.44.0 and Dart 3.12.0.
- `CupertinoSheetPage.builder` is now nullable because `scrollableBuilder` can be supplied instead. At least one of the two must be non-null.
- `CupertinoSheetPage.showDragHandle` and the matching extension helper parameters are now non-nullable booleans that default to `false`.
- Removed `CupertinoSheetPage.topGapRatio`; use `topGap` instead.
- Removed `CupertinoSheetPage.onWillPop`. Use `Page.canPop` and `Page.onPopInvoked` from the superclass to gate sheet dismissal.
- Removed `CupertinoSheetPage` route override parameters `transitionDuration`, `barrierColor`, `barrierDismissible`, and `barrierLabel`. Consumers that need them should wrap `CupertinoSheetRoute` directly.
- Removed `CupertinoDialogOverlay` and `CupertinoModalPopupOverlay` widgets. Add the corresponding `CupertinoDialogPage` / `CupertinoModalPopupPage` to your navigator instead.
- `CupertinoSheetPage.onBarrierTap` now replaces the default pop behavior (matching `CupertinoDialogPage` and `CupertinoModalPopupPage`) instead of running alongside it. Callbacks that previously expected the sheet to also pop must now call `Navigator.pop` explicitly.
- `CupertinoSheetPage._applyCustomizations` no longer wraps content in `Material`. Content is wrapped in `DecoratedBox` + `ClipPath` when `backgroundColor` or `shape` is supplied. Callers relying on Material ink/elevation inside the sheet need to add their own `Material` widget.

### Additions

- Added `CupertinoSheetPage.scrollableBuilder` and wired it to Flutter's native `CupertinoSheetRoute.scrollableBuilder` for coordinated scroll-to-dismiss behavior.
- Delegated Cupertino sheet `showDragHandle` and `topGap` behavior to Flutter's native `CupertinoSheetRoute`.
- Added `scrollableBuilder`, `topGap`, `key`, `name`, and `arguments` passthroughs to `NavigatorState.showCupertinoSheet`.
- Added `scrollableBuilder` and `topGap` passthroughs to `BuildContext.createCupertinoSheetPage`.

### Notes

- Flutter 3.44's `Navigator` change (flutter/flutter#182315) removes pages from `Navigator.pages` before the underlying route is disposed. Apps that mirror sheet state in `onDidRemovePage` will see callbacks fire earlier than before, but no code change is needed for the README examples.

### Migrating from 0.3.x

| 0.3.x                                                                                            | 1.0.0                                                  |
|--------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| `CupertinoSheetPage.topGapRatio: 0.2`                                                            | `CupertinoSheetPage.topGap: 0.2`                       |
| `CupertinoSheetPage(onWillPop: ...)`                                                             | `CupertinoSheetPage(canPop: false, onPopInvoked: ...)` |
| `CupertinoSheetPage(transitionDuration / barrierColor / barrierDismissible / barrierLabel: ...)` | Wrap `CupertinoSheetRoute` directly                    |
| `CupertinoDialogOverlay` widget                                                                  | `CupertinoDialogPage` in `Navigator.pages`             |
| `CupertinoModalPopupOverlay` widget                                                              | `CupertinoModalPopupPage` in `Navigator.pages`         |
| `onBarrierTap: () => doX(); // sheet also pops`                                                  | `onBarrierTap: () { doX(); Navigator.pop(context); }`  |

## [0.3.3] - 2026-02-17

- Fixed GitHub Actions publish flow to use the official pub.dev trusted publisher OIDC workflow.
- No public API changes.

## [0.3.2] - 2026-02-17

- Maintenance release to publish through the updated GitHub release pipeline.
- No public API changes.

## [0.3.1] - 2026-02-17

- Added compatibility updates for newer Flutter SDKs:
  - Updated `CupertinoSheetPage` internals to align with latest `CupertinoSheetRoute` API changes.
  - Kept custom sheet top gap behavior wired through the SDK route API.
- Added `Page` pop lifecycle passthrough support across popup pages via:
  - `canPop`
  - `onPopInvoked`
- Migrated Navigator 2 example and docs away from deprecated `onPopPage` to `onDidRemovePage`.
- Improved popup result handling in the Navigator 2 example using `onPopInvoked` plus route removal callbacks.

## [0.3.0] - 2025-08-16

- Enhanced **CupertinoSheetPage** documentation with important drag-to-dismiss behavior warnings for nested navigators.
- Updated example app to use go_router for modern declarative navigation patterns.

## [0.2.0] - 2025-06-04

- Added **CupertinoDialogPage** - Declarative alternative to `showCupertinoDialog`
  - Full iOS-style dialog support with fade and scale animations
  - Custom barrier tap handling with `onBarrierTap` callback
  - Semantic hints for accessibility with `barrierOnTapHint`
  - Customizable transition duration and animations
  - Complete integration with Navigator 2.0

## [0.1.0] - 2025-06-04

### Initial Release
- **Material Design Pages**
  - `DialogPage` - Declarative alternative to `showDialog`
  - `ModalBottomSheetPage` - Declarative alternative to `showModalBottomSheet`
  
- **Cupertino (iOS) Pages**
  - `CupertinoModalPopupPage` - Declarative alternative to `showCupertinoModalPopup`
  - `CupertinoSheetPage` - iOS-style sheet presentations
  
- **Custom/Raw Pages**
  - `RawDialogPage` - Base implementation for custom popup routes
  
- **Features**
  - Full Navigator 2.0 support
  - Type-safe with generics
  - State restoration support
  - Nested navigation support
  - Custom animations and transitions
  - Barrier customization
  - go_router compatibility
  
- **Developer Experience**
  - Comprehensive documentation
  - Extension methods for convenient navigation
  - Rich example application
  - Full API documentation
