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
  final Map<AppRoute, Completer<String?>> _pendingResults = {};

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  void _completeResult(AppRoute route, String? result) {
    _pendingResults.remove(route)?.complete(result);
  }

  Future<String?> _showPopup(AppRoute route) {
    if (_currentRoute != route) {
      _completeResult(_currentRoute, null);
    }
    // Repeated requests for the visible popup share its pending result.
    final completer = _pendingResults.putIfAbsent(
      route,
      Completer<String?>.new,
    );
    _currentRoute = route;
    notifyListeners();
    return completer.future;
  }

  @override
  void dispose() {
    for (final completer in _pendingResults.values) {
      completer.complete(null);
    }
    _pendingResults.clear();
    super.dispose();
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
                _completeResult(AppRoute.dialog, result);
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
                _completeResult(AppRoute.bottomSheet, result);
              }
            },
          ),
        if (_currentRoute == AppRoute.cupertinoDialog)
          CupertinoDialogPage<String>(
            key: const ValueKey('cupertino-dialog'),
            builder: (context) => const SampleCupertinoDialog(),
            onPopInvoked: (didPop, result) {
              if (didPop) {
                _completeResult(AppRoute.cupertinoDialog, result);
              }
            },
          ),
        if (_currentRoute == AppRoute.cupertinoScrollableSheet)
          CupertinoSheetPage<String>(
            key: const ValueKey('cupertino-scrollable-sheet'),
            scrollableBuilder: (context, scrollController) =>
                CupertinoScrollableSheetBody(
                  scrollController: scrollController,
                ),
            backgroundColor: CupertinoColors.systemGroupedBackground,
            onPopInvoked: (didPop, result) {
              if (didPop) {
                _completeResult(AppRoute.cupertinoScrollableSheet, result);
              }
            },
          ),
      ],
      onDidRemovePage: (page) {
        final removedRoute = switch (page.key) {
          ValueKey(value: 'dialog') => AppRoute.dialog,
          ValueKey(value: 'bottom-sheet') => AppRoute.bottomSheet,
          ValueKey(value: 'cupertino-dialog') => AppRoute.cupertinoDialog,
          ValueKey(value: 'cupertino-scrollable-sheet') =>
            AppRoute.cupertinoScrollableSheet,
          _ => AppRoute.home,
        };
        if (removedRoute == _currentRoute) {
          _currentRoute = AppRoute.home;
          notifyListeners();
        }
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (_currentRoute != configuration.route) {
      _completeResult(_currentRoute, null);
    }
    _currentRoute = configuration.route;
    notifyListeners();
  }

  Future<String?> showDialog() => _showPopup(AppRoute.dialog);

  Future<String?> showBottomSheet() => _showPopup(AppRoute.bottomSheet);

  Future<String?> showCupertinoDialog() => _showPopup(AppRoute.cupertinoDialog);

  Future<String?> showCupertinoScrollableSheet() =>
      _showPopup(AppRoute.cupertinoScrollableSheet);
}
