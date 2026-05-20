# Changelog

## [1.0.0] - 2026-05-20

- First stable release.
- BREAKING: Raised the minimum SDK requirements to Flutter 3.44.0 and Dart 3.12.0.
- BREAKING: `CupertinoSheetPage.builder` is now nullable because `scrollableBuilder` can be supplied instead.
- BREAKING: `CupertinoSheetPage.showDragHandle` and Cupertino sheet helper `showDragHandle` parameters are now non-nullable booleans that default to `false`.
- Added `CupertinoSheetPage.scrollableBuilder` and wired it to Flutter's native `CupertinoSheetRoute.scrollableBuilder` for coordinated scroll-to-dismiss behavior.
- BREAKING: Removed `topGapRatio`; use `topGap` instead.
- Delegated Cupertino sheet `showDragHandle` and `topGap` behavior to Flutter's native `CupertinoSheetRoute`.
- Added `scrollableBuilder`, `topGap`, `key`, `name`, and `arguments` passthroughs to `NavigatorState.showCupertinoSheet`.
- Added `scrollableBuilder` and `topGap` passthroughs to `BuildContext.createCupertinoSheetPage`.

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
