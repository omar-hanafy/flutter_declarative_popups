# Changelog

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
