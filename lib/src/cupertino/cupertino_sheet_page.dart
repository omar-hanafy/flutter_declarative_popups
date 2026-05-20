// Copyright (c) 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

/// A declarative [Page] that shows its content inside a Cupertino‑style sheet.
///
/// ### Why this wrapper exists
/// Flutter’s **[`CupertinoSheetRoute`][]** (added in the SDK around v3.26) is a
/// fully‑featured iOS sheet that supports stacking, nested navigation, and a
/// native drag‑to‑dismiss gesture.  The route, however, is **imperative‑only** –
/// you can `Navigator.push` it, but you cannot place it directly in a
/// Navigator 2.0 `pages:` list because a `Page` object is required there.
///
/// `CupertinoSheetPage` bridges that gap: it lets you use the new sheet in
/// declarative navigation while keeping 100% of the SDK’s animation and
/// gesture logic.
///
/// ### ⚠️  Drag‑to‑dismiss caveat
/// `CupertinoSheetRoute`’s private gesture controller calls:
///
/// ```dart
/// Navigator.of(context, rootNavigator: true).pop();
/// ```
///
/// That means **the sheet will always pop the _root_ `Navigator`**.  If you push
/// the sheet inside a *nested* navigator the drag gesture will ascend the tree
/// and remove the entire screen.
///
/// **To avoid surprises:**
/// * Push the sheet on the root navigator (`rootNavigator: true`), **or**
/// * Drive the root navigator declaratively and add this `CupertinoSheetPage`
///   to its `pages:` list, as shown in the example below.
///
/// If you really need the sheet inside a child navigator you must fork
/// `CupertinoSheetRoute` and change that `rootNavigator: true` call.
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
    this.onWillPop,
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
    // Route properties (rarely needed)
    this.transitionDuration,
    this.barrierColor,
    this.barrierDismissible,
    this.barrierLabel,
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
  /// Useful for controlling the nested navigator programmatically.
  final GlobalKey<NavigatorState>? nestedNavigatorKey;

  /// Callback to control whether the sheet can be popped.
  ///
  /// Only used when [useNestedNavigation] is true. Return `true` to allow
  /// the sheet to be dismissed, `false` to prevent dismissal.
  final Future<bool> Function()? onWillPop;

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

  /// Whether the sheet can be dismissed at all (by drag or programmatically).
  ///
  /// When `false`, the sheet becomes truly modal and can only be dismissed
  /// by calling Navigator.pop() with `rootNavigator: true`.
  ///
  /// Defaults to `true`.
  final bool isDismissible;

  /// Callback when the barrier (area outside the sheet) is tapped.
  ///
  /// When provided, this callback replaces the default dismiss behavior; the
  /// sheet will not pop unless the callback itself pops the navigator. Only
  /// invoked when the barrier is dismissible. Note that by default, iOS
  /// sheets have a transparent, non-dismissible barrier.
  final VoidCallback? onBarrierTap;

  /// Custom transition duration for the sheet animation.
  ///
  /// Defaults to 500ms to match iOS behavior. Only change this if you
  /// need custom animation timing.
  final Duration? transitionDuration;

  /// The color of the modal barrier (area outside the sheet).
  ///
  /// Defaults to transparent to match iOS behavior. Set to a semi-transparent
  /// black for a dimmed background effect.
  final Color? barrierColor;

  /// Whether tapping the barrier dismisses the sheet.
  ///
  /// Defaults to `false` to match iOS behavior. iOS sheets typically
  /// require dragging or an explicit close button.
  final bool? barrierDismissible;

  /// Semantic label for the barrier.
  ///
  /// Used by screen readers to describe the barrier. Only relevant if
  /// [barrierColor] is not fully transparent.
  final String? barrierLabel;

  @override
  Route<T> createRoute(BuildContext context) {
    final navigatorKey = useNestedNavigation
        ? nestedNavigatorKey ?? GlobalKey<NavigatorState>()
        : null;

    return _CustomizedCupertinoSheetRoute<T>(
      scrollableBuilder: (context, scrollController) {
        final content = useNestedNavigation
            ? _buildNestedNavigator(navigatorKey!, scrollController)
            : _buildContent(context, scrollController);

        return _applyCustomizations(context, content);
      },
      settings: this,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      topGap: topGap,
      // Behavior
      isDismissible: isDismissible,
      onBarrierTap: onBarrierTap,
      // Route overrides
      customTransitionDuration: transitionDuration,
      customBarrierColor: barrierColor,
      customBarrierDismissible: barrierDismissible,
      customBarrierLabel: barrierLabel,
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return scrollableBuilder?.call(context, scrollController) ??
        builder!(context);
  }

  Widget _buildNestedNavigator(
    GlobalKey<NavigatorState> navigatorKey,
    ScrollController scrollController,
  ) {
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
                  builder: (BuildContext context) {
                    final content = _buildContent(context, scrollController);

                    return PopScope(
                      canPop: false,
                      onPopInvokedWithResult:
                          (bool didPop, Object? result) async {
                            if (didPop) {
                              return;
                            }

                            if (onWillPop != null) {
                              final shouldPop = await onWillPop!();
                              if (shouldPop && context.mounted) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(result);
                              }
                            } else {
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(result);
                            }
                          },
                      child: content,
                    );
                  },
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

    if (constraints != null) {
      content = ConstrainedBox(constraints: constraints!, child: content);
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

    return content;
  }
}

/// Internal route that extends [CupertinoSheetRoute] with customization support.
class _CustomizedCupertinoSheetRoute<T> extends CupertinoSheetRoute<T> {
  _CustomizedCupertinoSheetRoute({
    required ScrollableWidgetBuilder scrollableBuilder,
    required RouteSettings settings,
    required bool enableDrag,
    required super.showDragHandle,
    super.topGap,
    // Behavior
    this.isDismissible = true,
    this.onBarrierTap,
    // Route overrides
    this.customTransitionDuration,
    this.customBarrierColor,
    this.customBarrierDismissible,
    this.customBarrierLabel,
  }) : super(
         scrollableBuilder: scrollableBuilder,
         settings: settings,
         enableDrag: enableDrag && isDismissible,
       );

  // Behavior customization
  final bool isDismissible;
  final VoidCallback? onBarrierTap;

  // Route property overrides
  final Duration? customTransitionDuration;
  final Color? customBarrierColor;
  final bool? customBarrierDismissible;
  final String? customBarrierLabel;

  @override
  Duration get transitionDuration =>
      customTransitionDuration ?? super.transitionDuration;

  @override
  Color? get barrierColor => customBarrierColor ?? super.barrierColor;

  @override
  bool get barrierDismissible =>
      isDismissible && (customBarrierDismissible ?? super.barrierDismissible);

  @override
  String? get barrierLabel => customBarrierLabel ?? super.barrierLabel;

  @override
  Widget buildModalBarrier() {
    if (onBarrierTap == null || !barrierDismissible) {
      return super.buildModalBarrier();
    }
    return GestureDetector(
      onTap: onBarrierTap,
      behavior: HitTestBehavior.opaque,
      child: super.buildModalBarrier(),
    );
  }

  @override
  bool get popGestureEnabled =>
      enableDrag && isDismissible && super.popGestureEnabled;
}
