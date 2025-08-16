import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
import '../shared/popup_demo_widget.dart';
import 'navigator_2_example.dart';

enum AppRoute {
  home,
  dialog,
  bottomSheet,
  cupertinoDialog,
}

class AppRoutePath {
  final AppRoute route;

  AppRoutePath.home() : route = AppRoute.home;
  AppRoutePath.dialog() : route = AppRoute.dialog;
  AppRoutePath.bottomSheet() : route = AppRoute.bottomSheet;
  AppRoutePath.cupertinoDialog() : route = AppRoute.cupertinoDialog;
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRoute _currentRoute = AppRoute.home;
  Completer<String?> dialogCompleter = Completer();
  Completer<String?> bottomSheetCompleter = Completer();
  Completer<String?> cupertinoDialogCompleter = Completer();

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

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
          ),
        if (_currentRoute == AppRoute.bottomSheet)
          ModalBottomSheetPage<String>(
            key: const ValueKey('bottom-sheet'),
            builder: (context) => const SampleBottomSheet(),
            showDragHandle: true,
          ),
        if (_currentRoute == AppRoute.cupertinoDialog)
          CupertinoDialogPage<String>(
            key: const ValueKey('cupertino-dialog'),
            builder: (context) => const SampleCupertinoDialog(),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Handle popup results
        if (_currentRoute == AppRoute.dialog && !dialogCompleter.isCompleted) {
          dialogCompleter.complete(result as String?);
          dialogCompleter = Completer(); // Reset for next use
        } else if (_currentRoute == AppRoute.bottomSheet &&
            !bottomSheetCompleter.isCompleted) {
          bottomSheetCompleter.complete(result as String?);
          bottomSheetCompleter = Completer();
        } else if (_currentRoute == AppRoute.cupertinoDialog &&
            !cupertinoDialogCompleter.isCompleted) {
          cupertinoDialogCompleter.complete(result as String?);
          cupertinoDialogCompleter = Completer();
        }

        _currentRoute = AppRoute.home;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    _currentRoute = configuration.route;
    notifyListeners();
  }

  void showDialog() {
    _currentRoute = AppRoute.dialog;
    notifyListeners();
  }

  void showBottomSheet() {
    _currentRoute = AppRoute.bottomSheet;
    notifyListeners();
  }

  void showCupertinoDialog() {
    _currentRoute = AppRoute.cupertinoDialog;
    notifyListeners();
  }
}
