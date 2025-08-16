# flutter_declarative_popups

**Declarative popup routes for Navigator 2.0 & your favourite routing packages**
Material, Cupertino, and fully‑custom pop‑ups with type‑safe results, deep‑linking, and state restoration.

[![Pub Version](https://img.shields.io/pub/v/flutter_declarative_popups.svg)](https://pub.dev/packages/flutter_declarative_popups) 
[![Flutter](https://img.shields.io/badge/flutter-3.26%2B-blue)](https://flutter.dev/) ![Null‑safety](https://img.shields.io/badge/null--safety-%E2%9C%93-success)

> `flutter_declarative_popups` lets you treat pop‑ups like *pages* so they play nicely with Navigator 2.0, `go_router`, `auto_route`, and the browser URL.

------

## ✨ Features

| ✅                              | Feature                                                                                                                       |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Declarative `Page`subclasses   | `DialogPage`, `ModalBottomSheetPage`, `CupertinoDialogPage`, `CupertinoModalPopupPage`, `CupertinoSheetPage`, `RawDialogPage` |
| Type‑safe result values        | `final result = await context.push<String>("/dialog");`                                                                       |
| Deep linking & browser history | Pop‑ups get their own **URL path**                                                                                            |
| Works everywhere               | Android • iOS • Web • macOS • Windows • Linux                                                                                 |
| State restoration              | Reload the app and come back to the same pop‑up                                                                               |
| Mix‑and‑match                  | Use with **Navigator 2.0**, classic **Navigator 1.0**, `go_router`, **or** `auto_route`                                       |

------

## 🚀 Getting started

```yaml
# pubspec.yaml
dependencies:
  flutter_declarative_popups: ^0.3.0
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
        builder: (_) => const ConfirmDeleteDialog(),
      ),
  ],
  onPopPage: (route, result) {
    if (!route.didPop(result)) return false;
    // handle `result` here
    return true;
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
- `go_router/` – v15.1.2 integration
- `navigator_1/` – imperative push/pop

------

## 🧩 API overview

| Class                        | Description                                                                          |
|------------------------------|--------------------------------------------------------------------------------------|
| `DialogPage<T>`              | Material `AlertDialog` as a page. `barrierDismissible`, `barrierColor`, transitions… |
| `ModalBottomSheetPage<T>`    | Material sheet with drag‑handle & custom shape support                               |
| `CupertinoDialogPage<T>`     | iOS‑style alert dialog                                                               |
| `CupertinoModalPopupPage<T>` | iOS action sheet / picker style                                                      |
| `CupertinoSheetPage<T>`      | iOS sheet with drag‑to‑dismiss gesture (requires root navigator)                     |
| `RawDialogPage<T>`           | Bring‑your‑own builder for complete control                                          |

All pages extend **`Page<T>`**, so they slot straight into any declarative navigator.

------

## 📦 Version Requirements

| Package                       | Min Flutter | Min Dart | Notes                                                           |
|-------------------------------|-------------|----------|------------------------------------------------------------------|
| flutter_declarative_popups    | 3.26+       | 3.5+     | Uses `CupertinoSheetRoute`, barrier semantics, `AnimationStyle` |

------

## 🔄 State & Route Updates

**Important:** Page properties are immutable once created. To update popup properties at runtime:
- Pass a new `ValueKey` to the page when state changes
- The framework will rebuild the route with new properties

```dart
DialogPage<bool>(
  key: ValueKey('dialog_$dialogVersion'), // Change key to update
  barrierDismissible: someCondition,
  builder: (_) => MyDialog(),
)
```

------

## 🛣️ Deep linking & state restoration

Because every pop‑up is a real page, you can:

- open `/dialog` directly from a push‑notification or web link
- use the browser back button to close the dialog
- rely on `restorationScopeId` to survive hot‑restart & process death

No extra work required – just include the page in your `pages:` list or router config.

------

## 🗺️ Roadmap

- Built‑in **transition presets** (fade, scale, slide)
- `PersistentBottomSheetPage`
- Sheet stacking API samples
- More samples + video walkthrough

------

## 🤝 Contributing

1. Fork the repo & create a branch
2. `dart format . && flutter analyze`
3. Add / update tests in `test/`
4. Open a PR – **all welcome!**

------

## 📄 License

BSD 3-Clause © 2025 Omar Khaled Hanafy - see the [LICENSE](LICENSE) file for details
