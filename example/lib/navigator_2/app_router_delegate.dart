import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
import '../shared/popup_demo_widget.dart';
import 'navigator_2_example.dart';

enum AppRoute {
  home,
  dialog,
  bottomSheet,
  cupertinoDialog,
  cupertinoScrollableSheet,
}

class AppRoutePath {
  final AppRoute route;

  AppRoutePath.home() : route = AppRoute.home;
  AppRoutePath.dialog() : route = AppRoute.dialog;
  AppRoutePath.bottomSheet() : route = AppRoute.bottomSheet;
  AppRoutePath.cupertinoDialog() : route = AppRoute.cupertinoDialog;
  AppRoutePath.cupertinoScrollableSheet()
      : route = AppRoute.cupertinoScrollableSheet;
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRoute _currentRoute = AppRoute.home;
  Completer<String?> dialogCompleter = Completer();
  Completer<String?> bottomSheetCompleter = Completer();
  Completer<String?> cupertinoDialogCompleter = Completer();
  Completer<String?> cupertinoScrollableSheetCompleter = Completer();
  String? _dialogResult;
  String? _bottomSheetResult;
  String? _cupertinoDialogResult;
  String? _cupertinoScrollableSheetResult;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  void _cacheDialogResult(String? result) {
    _dialogResult = result;
  }

  void _cacheBottomSheetResult(String? result) {
    _bottomSheetResult = result;
  }

  void _cacheCupertinoDialogResult(String? result) {
    _cupertinoDialogResult = result;
  }

  void _cacheCupertinoScrollableSheetResult(String? result) {
    _cupertinoScrollableSheetResult = result;
  }

  void _resolveDialogResult() {
    if (dialogCompleter.isCompleted) {
      return;
    }
    dialogCompleter.complete(_dialogResult);
    _dialogResult = null;
    dialogCompleter = Completer();
  }

  void _resolveBottomSheetResult() {
    if (bottomSheetCompleter.isCompleted) {
      return;
    }
    bottomSheetCompleter.complete(_bottomSheetResult);
    _bottomSheetResult = null;
    bottomSheetCompleter = Completer();
  }

  void _resolveCupertinoDialogResult() {
    if (cupertinoDialogCompleter.isCompleted) {
      return;
    }
    cupertinoDialogCompleter.complete(_cupertinoDialogResult);
    _cupertinoDialogResult = null;
    cupertinoDialogCompleter = Completer();
  }

  void _resolveCupertinoScrollableSheetResult() {
    if (cupertinoScrollableSheetCompleter.isCompleted) {
      return;
    }
    cupertinoScrollableSheetCompleter.complete(_cupertinoScrollableSheetResult);
    _cupertinoScrollableSheetResult = null;
    cupertinoScrollableSheetCompleter = Completer();
  }

  @override
  AppRoutePath? get currentConfiguration {
    switch (_currentRoute) {
      case AppRoute.home:
        return AppRoutePath.home();
      case AppRoute.dialog:
        return AppRoutePath.dialog();
      case AppRoute.bottomSheet:
        return AppRoutePath.bottomSheet();
      case AppRoute.cupertinoDialog:
        return AppRoutePath.cupertinoDialog();
      case AppRoute.cupertinoScrollableSheet:
        return AppRoutePath.cupertinoScrollableSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('home'),
          child: Navigator2HomePage(routerDelegate: this),
        ),
        if (_currentRoute == AppRoute.dialog)
          DialogPage<String>(
            key: const ValueKey('dialog'),
            builder: (context) => const SampleDialog(),
            onPopInvoked: (didPop, result) {
              if (didPop) {
                _cacheDialogResult(result);
              }
            },
          ),
        if (_currentRoute == AppRoute.bottomSheet)
          ModalBottomSheetPage<String>(
            key: const ValueKey('bottom-sheet'),
            builder: (context) => const SampleBottomSheet(),
            showDragHandle: true,
            onPopInvoked: (didPop, result) {
              if (didPop) {
                _cacheBottomSheetResult(result);
              }
            },
          ),
        if (_currentRoute == AppRoute.cupertinoDialog)
          CupertinoDialogPage<String>(
            key: const ValueKey('cupertino-dialog'),
            builder: (context) => const SampleCupertinoDialog(),
            onPopInvoked: (didPop, result) {
              if (didPop) {
                _cacheCupertinoDialogResult(result);
              }
            },
          ),
        if (_currentRoute == AppRoute.cupertinoScrollableSheet)
          CupertinoSheetPage<String>(
            key: const ValueKey('cupertino-scrollable-sheet'),
            scrollableBuilder: (context, scrollController) =>
                CupertinoScrollableSheetBody(
                    scrollController: scrollController),
            backgroundColor: CupertinoColors.systemGroupedBackground,
            onPopInvoked: (didPop, result) {
              if (didPop) {
                _cacheCupertinoScrollableSheetResult(result);
              }
            },
          ),
      ],
      onDidRemovePage: (page) {
        if (page.key == const ValueKey('dialog')) {
          _resolveDialogResult();
        } else if (page.key == const ValueKey('bottom-sheet')) {
          _resolveBottomSheetResult();
        } else if (page.key == const ValueKey('cupertino-dialog')) {
          _resolveCupertinoDialogResult();
        } else if (page.key == const ValueKey('cupertino-scrollable-sheet')) {
          _resolveCupertinoScrollableSheetResult();
        }
        _currentRoute = AppRoute.home;
        notifyListeners();
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentRoute = configuration.route;
    notifyListeners();
  }

  void showDialog() {
    _dialogResult = null;
    _currentRoute = AppRoute.dialog;
    notifyListeners();
  }

  void showBottomSheet() {
    _bottomSheetResult = null;
    _currentRoute = AppRoute.bottomSheet;
    notifyListeners();
  }

  void showCupertinoDialog() {
    _cupertinoDialogResult = null;
    _currentRoute = AppRoute.cupertinoDialog;
    notifyListeners();
  }

  void showCupertinoScrollableSheet() {
    _cupertinoScrollableSheetResult = null;
    _currentRoute = AppRoute.cupertinoScrollableSheet;
    notifyListeners();
  }
}
