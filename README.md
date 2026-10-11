# flutter_declarative_popups

**Declarative popup routes for Navigator 2.0 & your favourite routing packages**
Material, Cupertino, and fully‑custom pop‑ups with type‑safe results, deep‑linking, and state restoration.

[![Pub Version](https://img.shields.io/pub/v/flutter_declarative_popups.svg)](https://pub.dev/packages/flutter_declarative_popups) 
[![Flutter](https://img.shields.io/badge/flutter-3.47.7%2B-blue)](https://flutter.dev/) ![Null‑safety](https://img.shields.io/badge/null--safety-%E2%9C%93-success)

> `flutter_declarative_popups` lets you treat pop‑ups like *pages* so they play nicely with Navigator 2.0, `go_router`, `auto_route`, and the browser URL.

------

## ✨ Features

| ✅                              | Feature                                                                                                                       |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Declarative `Page`subclasses   | `DialogPage`, `ModalBottomSheetPage`, `CupertinoDialogPage`, `CupertinoModalPopupPage`, `CupertinoSheetPage`, `RawDialogPage` |
| Type‑safe result values        | `final result = await context.push<String>("/dialog");`                                                                       |
| Deep linking & browser history | Pop‑ups get their own **URL path**                                                                                            |
| Works everywhere               | Android • iOS • Web • macOS • Windows • Linux                                                                                 |
| State restoration              | Integrates with app and navigator restoration scopes                                                                               |
| Mix‑and‑match                  | Use with **Navigator 2.0**, classic **Navigator 1.0**, `go_router`, **or** `auto_route`                                       |

------

## 🚀 Getting started

```yaml
# pubspec.yaml
dependencies:
  flutter_declarative_popups: ^2.0.0
```

```dart
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
```

------

## 🔹 Quick examples

### Navigator 2.0

```dart
Navigator(
  pages: [
    MaterialPage(child: HomeScreen()),
    if (showDialog)
      DialogPage<String>(
        key: const ValueKey('confirm-dialog'),
        builder: (_) => const ConfirmDeleteDialog(),
      ),
  ],
  onDidRemovePage: (page) {
    if (page.key == const ValueKey('confirm-dialog')) {
      // handle removal here
    }
  },
);
```

### `go_router`

```dart
GoRoute(
  path: 'dialog',
  pageBuilder: (_, state) => DialogPage<String>(
    key: state.pageKey,
    builder: (_) => const ConfirmDeleteDialog(),
  ),
),
final result = await context.push<String>('/dialog');
```

### Classic Navigator 1.0

```dart
final result = await Navigator.of(context).push<String>(
  DialogPage<String>(builder: (_) => const ConfirmDeleteDialog())
      .createRoute(context),
);
```

More complete examples live in the **[`example/`](example/)** folder:

- `navigator_2/` – hand‑rolled RouterDelegate
- `go_router/` – v18.0.2 integration
- `navigator_1/` – imperative push/pop

------

## 🧩 API overview

| Class                        | Description                                                                          |
|------------------------------|--------------------------------------------------------------------------------------|
| `DialogPage<T>`              | Material `AlertDialog` as a page. `barrierDismissible`, `barrierColor`, transitions… |
| `ModalBottomSheetPage<T>`    | Material sheet with drag‑handle & custom shape support                               |
| `CupertinoDialogPage<T>`     | iOS‑style alert dialog                                                               |
| `CupertinoModalPopupPage<T>` | iOS action sheet / picker style                                                      |
| `CupertinoSheetPage<T>`      | iOS sheet with native scroll-to-dismiss (via `scrollableBuilder`) and drag-to-dismiss in the owning navigator |
| `RawDialogPage<T>`           | Bring‑your‑own builder for complete control                                          |

All pages extend **`Page<T>`**, so they slot straight into any declarative navigator.

------

## 📦 Version Requirements

| Package                       | Min Flutter | Min Dart | Notes                                                           |
|-------------------------------|-------------|----------|------------------------------------------------------------------|
| flutter_declarative_popups    | 3.47.7+     | 3.13.5+    | Uses `CupertinoSheetRoute.scrollableBuilder`, barrier semantics, `AnimationStyle` |

The example projects target iOS 15 and macOS 12, matching the SDK's current
project configuration.

------

## ⬆️ Migrating to 2.0.0

Upgrade to Flutter **3.47.7** (Dart **3.13.5**) or newer. Existing page constructors
remain available. Pages with the same key now update their content and supported
options when rebuilt. Custom barrier callbacks replace automatic dismissal, and
user dismissal respects `Page.canPop` and `PopScope` where described by the API.

See the [migration guide](doc/migration_guide.md) for result handling,
`onDidRemovePage`, nested navigation, and restoration setup.

### From 0.3.x

| 0.3.x | 1.0.0 |
| --- | --- |
| `CupertinoSheetPage.topGapRatio` | `CupertinoSheetPage.topGap` |
| `CupertinoSheetPage(onWillPop: ...)` | `CupertinoSheetPage(canPop: false, onPopInvoked: ...)` |
| `CupertinoSheetPage(transitionDuration / barrierColor / barrierDismissible / barrierLabel: ...)` | Wrap `CupertinoSheetRoute` directly |
| `CupertinoDialogOverlay` / `CupertinoModalPopupOverlay` widgets | Add the matching `CupertinoDialogPage` / `CupertinoModalPopupPage` to `Navigator.pages` |
| `onBarrierTap` previously ran alongside the default pop on the sheet | `onBarrierTap` now replaces the default pop. Pop manually if you still want dismissal. |

------

## 🔄 State & Route Updates

Rebuild a page with the same type and key to update its content and supported
route options while preserving the route and widget state:

```dart
DialogPage<bool>(
  key: const ValueKey('confirmation'),
  barrierDismissible: someCondition,
  builder: (_) => MyDialog(message: currentMessage),
)
```

Use a new key when you intend to create a new popup. Animation controllers and
other options fixed by the underlying Flutter route may require a replacement;
see each page's API documentation.

------

## 🛣️ Deep linking & state restoration

Because every pop‑up is a real page, you can:

- open `/dialog` directly from a push‑notification or web link
- use the browser back button to close the dialog
- restore popup routes when the app restores the state that builds its page list

Deep links and browser history require a configured router. For restoration,
configure the app and navigator restoration scopes, give pages `restorationId`
values, and restore the state that decides which pages are present. A page alone
does not persist application state or survive a hot restart.

------

## 🗺️ Future ideas

- `PersistentBottomSheetPage`
- Sheet stacking API samples
- Built‑in transition presets

If any of these would help your app, open an issue and we can scope it.

------

## 🤝 Contributing

1. Fork the repo & create a branch
2. `dart format . && flutter analyze`
3. Add / update tests in `test/`
4. Open a PR – **all welcome!**

------

## 📄 License

BSD 3-Clause © 2025-2026 Omar Khaled Hanafy - see the [LICENSE](LICENSE) file for details
