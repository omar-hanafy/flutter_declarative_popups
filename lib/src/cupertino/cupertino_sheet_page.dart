// Copyright (c) 2025-2026. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_declarative_popups/src/utils/page_route.dart';

/// A declarative [Page] that shows its content inside a Cupertino‑style sheet.
///
/// ### Why this wrapper exists
/// Flutter’s **[`CupertinoSheetRoute`][]** is a
/// fully‑featured iOS sheet that supports stacking, nested navigation, and a
/// native drag‑to‑dismiss gesture.  The route, however, is **imperative‑only** –
/// you can `Navigator.push` it, but you cannot place it directly in a
/// Navigator 2.0 `pages:` list because a `Page` object is required there.
///
/// `CupertinoSheetPage` bridges that gap: it lets you use the new sheet in
/// declarative navigation while keeping 100% of the SDK’s animation and
/// gesture logic.
///
/// Drag dismissal uses the navigator that owns the sheet route. When closing a
/// sheet in a nested navigator programmatically, use that navigator rather than
/// [CupertinoSheetRoute.popSheet], whose helper targets the root navigator.
///
/// ### Example (declarative)
/// ```dart
/// class AppRouterDelegate extends RouterDelegate<void>
///     with ChangeNotifier, PopNavigatorRouterDelegateMixin<void> {
///   bool _showSheet = false;
///   // … navigatorKey etc.
///   @override
///   Widget build(BuildContext context) {
///     return Navigator(
///       pages: [
///         MaterialPage(child: HomeScreen(onOpen: () => _showSheet = true)),
///         if (_showSheet)
///           CupertinoSheetPage(
///             builder: (_) => SheetBody(onClose: () => _showSheet = false),
///           ),
///       ],
///       onDidRemovePage: (page) {
///         if (page is CupertinoSheetPage) _showSheet = false;
///       },
///     );
///   }
/// }
/// ```
///
/// [`CupertinoSheetRoute`]: https://api.flutter.dev/flutter/cupertino/CupertinoSheetRoute-class.html
class CupertinoSheetPage<T> extends Page<T> {
  const CupertinoSheetPage({
    this.builder,
    this.scrollableBuilder,
    // Navigation behavior
    this.useNestedNavigation = false,
    this.nestedNavigatorKey,
    // Sheet appearance
    this.backgroundColor,
    this.shape,
    this.showDragHandle = false,
    this.topGap,
    this.constraints,
    this.useSafeArea = false,
    // Sheet behavior
    this.enableDrag = true,
    this.isDismissible = true,
    this.onBarrierTap,
    // Page properties
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  }) : assert(
         builder != null || scrollableBuilder != null,
         'Either builder or scrollableBuilder must not be null.',
       );

  /// Builds the primary content of the sheet.
  ///
  /// The builder should create the main widget tree for the sheet's content.
  /// Provide either this or [scrollableBuilder].
  final WidgetBuilder? builder;

  /// Builds scrollable sheet content using Flutter's native sheet controller.
  ///
  /// If the returned scrollable uses the provided [ScrollController], dragging
  /// downward from the top of the scrollable can dismiss the sheet.
  final ScrollableWidgetBuilder? scrollableBuilder;

  /// Whether to wrap the content in a nested [Navigator].
  ///
  /// When `true`, navigation within the sheet will be isolated from the main
  /// app navigation. This is useful for multi-step flows within a sheet.
  ///
  /// Defaults to `false`.
  final bool useNestedNavigation;

  /// Optional key for the nested navigator when [useNestedNavigation] is true.
  ///
  /// Useful for controlling the nested navigator programmatically. To gate
  /// dismissal of the sheet, use [Page.canPop] and [Page.onPopInvoked] on
  /// the page itself.
  final GlobalKey<NavigatorState>? nestedNavigatorKey;

  /// The background color of the sheet.
  ///
  /// If null, the sheet will use the default background from the current theme.
  /// Consider using [CupertinoColors] for iOS-appropriate colors.
  final Color? backgroundColor;

  /// The shape applied to the sheet when [backgroundColor] or this property
  /// is provided.
  ///
  /// If null but a [backgroundColor] is supplied, defaults to top-rounded
  /// corners (12.0 radius) to match the iOS sheet look. When both this and
  /// [backgroundColor] are null, the SDK's native sheet styling is used and
  /// no extra wrapper is inserted.
  final ShapeBorder? shape;

  /// Whether to show a drag handle at the top of the sheet.
  ///
  /// The handle is a small horizontal bar that provides a visual affordance
  /// for dragging. Common in iOS sheets.
  ///
  /// Defaults to `false`.
  final bool showDragHandle;

  /// The ratio of screen height reserved for the gap at the top.
  ///
  /// If null, defers to [CupertinoSheetRoute]'s default top gap (matching
  /// native iOS behavior). Set to 0.0 for a full-screen sheet.
  ///
  /// Updating between two explicit values preserves the route and content
  /// state. Changing between null and an explicit value replaces the route,
  /// because the SDK initializes its transition mode from that distinction.
  final double? topGap;

  /// Additional constraints to apply to the sheet.
  ///
  /// Useful for limiting the sheet's width on large screens or setting
  /// a minimum/maximum height.
  final BoxConstraints? constraints;

  /// Whether to wrap the content in a [SafeArea].
  ///
  /// When true, the sheet content will avoid system UI intrusions.
  /// Default is false as sheets typically handle this themselves.
  final bool useSafeArea;

  /// Whether the sheet can be dismissed by dragging down.
  ///
  /// Defaults to `true`. Set to `false` for modal sheets that require
  /// explicit dismissal (e.g., forms that must be completed).
  final bool enableDrag;

  /// Whether the sheet can be dismissed by dragging or tapping its barrier.
  ///
  /// When false, these user interactions are disabled. Use [Page.canPop] or
  /// [PopScope] to also block back navigation. [Navigator.pop] can still close
  /// the sheet explicitly.
  ///
  /// Defaults to `true`.
  final bool isDismissible;

  /// Callback when the barrier (area outside the sheet) is tapped.
  ///
  /// When provided, this callback replaces the default dismiss behavior; the
  /// sheet will not pop unless the callback itself pops the navigator. Only
  /// invoked when [isDismissible] is true. Without this callback, the native
  /// transparent barrier remains non-dismissible.
  final VoidCallback? onBarrierTap;

  @override
  Route<T> createRoute(BuildContext context) {
    return _CupertinoSheetRoute<T>(page: this, context: context);
  }

  @override
  bool canUpdate(Page<dynamic> other) {
    if (!super.canUpdate(other)) {
      return false;
    }
    final previous = other as CupertinoSheetPage<T>;
    // The SDK caches whether a top gap was explicitly supplied for transitions.
    return (topGap == null) == (previous.topGap == null);
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return scrollableBuilder?.call(context, scrollController) ??
        builder!(context);
  }

  Widget _buildNestedNavigator(GlobalKey<NavigatorState> navigatorKey) {
    return NavigatorPopHandler(
      onPopWithResult: (T? result) {
        navigatorKey.currentState?.maybePop();
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: '/',
        onGenerateInitialRoutes:
            (NavigatorState navigator, String initialRouteName) {
              return <Route<void>>[
                CupertinoPageRoute<void>(
                  builder: (_) => _NestedSheetContent<T>(),
                ),
              ];
            },
      ),
    );
  }

  Widget _applyCustomizations(BuildContext context, Widget widget) {
    var content = widget;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    if (backgroundColor != null || shape != null) {
      final effectiveShape =
          shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          );
      content = DecoratedBox(
        decoration: ShapeDecoration(
          color:
              backgroundColor ??
              CupertinoColors.systemBackground.resolveFrom(context),
          shape: effectiveShape,
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: effectiveShape),
          child: content,
        ),
      );
    }

    if (constraints != null) {
      // The native sheet supplies tight screen constraints. Align loosens them
      // so that the requested maximum width and height can take effect.
      content = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: constraints!, child: content),
      );
    }

    return content;
  }
}

class _NestedSheetContentScope<T> extends InheritedWidget {
  const _NestedSheetContentScope({
    required this.page,
    required this.scrollController,
    required super.child,
  });

  final CupertinoSheetPage<T> page;
  final ScrollController scrollController;

  @override
  bool updateShouldNotify(_NestedSheetContentScope<T> oldWidget) =>
      page != oldWidget.page || scrollController != oldWidget.scrollController;
}

class _NestedSheetContent<T> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_NestedSheetContentScope<T>>()!;
    return scope.page._buildContent(context, scope.scrollController);
  }
}

class _CupertinoSheetRoute<T> extends CupertinoSheetRoute<T>
    with PopupPageRoute<T, CupertinoSheetPage<T>>, PopupDismissalGuard<T> {
  _CupertinoSheetRoute({
    required CupertinoSheetPage<T> page,
    required BuildContext context,
  }) : _defaultBarrierLabel = CupertinoLocalizations.of(context)
           .modalBarrierDismissLabel,
       super(
         scrollableBuilder: (context, controller) =>
             page._buildContent(context, controller),
         settings: page,
         topGap: page.topGap,
       );

  final String _defaultBarrierLabel;
  final GlobalKey<NavigatorState> _nestedNavigatorKey =
      GlobalKey<NavigatorState>();
  final ScrollController _nonDismissibleScrollController = ScrollController();

  @override
  ScrollableWidgetBuilder get scrollableBuilder => _buildSheetContent;

  Widget _buildSheetContent(BuildContext context, ScrollController controller) {
    // The SDK's scroll-linked controller can dismiss independently of the outer
    // drag detector. Use an ordinary controller while dismissal is blocked.
    final effectiveController = enableDrag
        ? controller
        : _nonDismissibleScrollController;
    final content = page.useNestedNavigation
        ? _NestedSheetContentScope<T>(
            page: page,
            scrollController: effectiveController,
            child: page._buildNestedNavigator(
              page.nestedNavigatorKey ?? _nestedNavigatorKey,
            ),
          )
        : page._buildContent(context, effectiveController);
    return page._applyCustomizations(context, preserveContent(content));
  }

  @override
  bool get enableDrag =>
      page.enableDrag && page.isDismissible && userDismissalAllowed;

  @override
  bool get showDragHandle => page.showDragHandle;

  @override
  double get topGap => page.topGap ?? super.topGap;

  @override
  bool get barrierDismissible =>
      page.isDismissible && page.onBarrierTap != null;

  @override
  String? get barrierLabel => barrierDismissible ? _defaultBarrierLabel : null;

  @override
  Widget buildModalBarrier() {
    final barrier = super.buildModalBarrier();
    if (!barrierDismissible) {
      return barrier;
    }
    return customizeModalBarrier(
      barrier,
      onDismiss: () {
        if (isCurrent) {
          page.onBarrierTap!();
        }
      },
    );
  }

  @override
  bool get popGestureEnabled => enableDrag && super.popGestureEnabled;

  @override
  void dispose() {
    _nonDismissibleScrollController.dispose();
    super.dispose();
  }
}
