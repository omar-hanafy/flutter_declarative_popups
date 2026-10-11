import 'package:flutter/widgets.dart';

/// Keeps a popup route's content and animation durations in sync with its page.
mixin PopupPageRoute<T, P extends Page<T>> on ModalRoute<T> {
  P get page => settings as P;

  final GlobalKey _contentKey = GlobalKey();
  RouteSettings? _previousSettings;

  Widget preserveContent(Widget child) =>
      KeyedSubtree(key: _contentKey, child: child);

  bool get synchronizeAnimationDurations => true;

  @override
  void changedInternalState() {
    final settingsChanged = _previousSettings != settings;
    _previousSettings = settings;
    super.changedInternalState();
    if (settingsChanged) {
      if (synchronizeAnimationDurations) {
        controller?.duration = transitionDuration;
        controller?.reverseDuration = reverseTransitionDuration;
      }
      // ModalRoute caches buildPage. A new Page must invalidate that cache,
      // while keeping the route and the state of its existing content alive.
      super.changedExternalState();
    }
  }
}

/// Rebuilds dismissal controls when a descendant PopScope changes its policy.
mixin PopupDismissalGuard<T> on ModalRoute<T> {
  final Set<PopEntry<Object?>> _popEntries = <PopEntry<Object?>>{};
  bool _refreshScheduled = false;
  bool _disposed = false;

  bool get userDismissalAllowed =>
      popDisposition != RoutePopDisposition.doNotPop;

  @override
  void registerPopEntry(PopEntry<Object?> popEntry) {
    super.registerPopEntry(popEntry);
    _popEntries.add(popEntry);
    popEntry.canPopNotifier.addListener(_refreshDismissalState);
    _refreshDismissalState();
  }

  @override
  void unregisterPopEntry(PopEntry<Object?> popEntry) {
    popEntry.canPopNotifier.removeListener(_refreshDismissalState);
    _popEntries.remove(popEntry);
    super.unregisterPopEntry(popEntry);
    _refreshDismissalState();
  }

  void _refreshDismissalState() {
    if (_disposed || _refreshScheduled) {
      return;
    }
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!_disposed && navigator != null) {
        changedExternalState();
      }
    });
    // A custom PopEntry can change its notifier while the app is idle.
    // Post-frame callbacks alone do not request the frame that runs them.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final popEntry in _popEntries) {
      popEntry.canPopNotifier.removeListener(_refreshDismissalState);
    }
    _popEntries.clear();
    super.dispose();
  }
}

/// Changes barrier actions without competing with its gesture recognizer.
Widget customizeModalBarrier(
  Widget barrier, {
  VoidCallback? onDismiss,
  String? semanticsOnTapHint,
}) {
  if (barrier is AnimatedModalBarrier) {
    return AnimatedModalBarrier(
      color: barrier.color,
      dismissible: barrier.dismissible,
      onDismiss: onDismiss,
      semanticsLabel: barrier.semanticsLabel,
      barrierSemanticsDismissible: barrier.barrierSemanticsDismissible,
      clipDetailsNotifier: barrier.clipDetailsNotifier,
      semanticsOnTapHint: semanticsOnTapHint ?? barrier.semanticsOnTapHint,
    );
  }
  if (barrier is ModalBarrier) {
    return ModalBarrier(
      color: barrier.color,
      dismissible: barrier.dismissible,
      onDismiss: onDismiss,
      semanticsLabel: barrier.semanticsLabel,
      barrierSemanticsDismissible: barrier.barrierSemanticsDismissible,
      clipDetailsNotifier: barrier.clipDetailsNotifier,
      semanticsOnTapHint: semanticsOnTapHint ?? barrier.semanticsOnTapHint,
    );
  }
  throw StateError('Unexpected modal barrier: ${barrier.runtimeType}');
}
