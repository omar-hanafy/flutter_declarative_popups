import 'package:flutter/material.dart';
import 'app_router_delegate.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = routeInformation.uri;

    // Handle the various paths
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.home();
    }

    if (uri.pathSegments.length == 1) {
      final segment = uri.pathSegments[0];
      switch (segment) {
        case 'dialog':
          return AppRoutePath.dialog();
        case 'bottom-sheet':
          return AppRoutePath.bottomSheet();
        case 'cupertino-dialog':
          return AppRoutePath.cupertinoDialog();
        default:
          return AppRoutePath.home();
      }
    }

    return AppRoutePath.home();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    switch (configuration.route) {
      case AppRoute.home:
        return RouteInformation(uri: Uri.parse('/'));
      case AppRoute.dialog:
        return RouteInformation(uri: Uri.parse('/dialog'));
      case AppRoute.bottomSheet:
        return RouteInformation(uri: Uri.parse('/bottom-sheet'));
      case AppRoute.cupertinoDialog:
        return RouteInformation(uri: Uri.parse('/cupertino-dialog'));
    }
  }
}
