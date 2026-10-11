import 'dart:ui' show SemanticsAction, SemanticsActionEvent;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
import 'package:flutter_test/flutter_test.dart';

enum _PopupKind { dialog, bottomSheet, cupertinoDialog, popup, sheet, raw }

void main() {
  group('Declarative page updates', () {
    for (final kind in _PopupKind.values) {
      testWidgets(
        '${kind.name} updates its builder and preserves content state',
        (tester) async {
          final pages = ValueNotifier<Page<void>?>(
            _page(kind, builder: (_) => _counter('first')),
          );
          addTearDown(pages.dispose);
          await _pumpPages(tester, pages);

          final state = tester.state(find.byType(_CounterBody));
          final route = ModalRoute.of(tester.element(find.text('first')));
          await tester.tap(find.text('Increment'));
          await tester.pump();
          expect(find.text('Count: 1'), findsOneWidget);

          pages.value = _page(kind, builder: (_) => _counter('second'));
          await tester.pumpAndSettle();

          expect(find.text('first'), findsNothing);
          expect(find.text('second'), findsOneWidget);
          expect(find.text('Count: 1'), findsOneWidget);
          expect(tester.state(find.byType(_CounterBody)), same(state));
          expect(
            ModalRoute.of(tester.element(find.text('second'))),
            same(route),
          );
        },
      );
    }

    for (final kind in _PopupKind.values.where(
      (kind) => kind != _PopupKind.sheet,
    )) {
      testWidgets('${kind.name} updates barrier and focus options', (
        tester,
      ) async {
        final pages = ValueNotifier<Page<void>?>(
          _page(
            kind,
            builder: (_) => _counter('Popup'),
            barrierDismissible: false,
            barrierColor: Colors.red,
            requestFocus: false,
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final route = ModalRoute.of(tester.element(find.text('Popup')))!;
        expect(route.barrierDismissible, isFalse);
        expect(route.barrierColor, Colors.red);
        expect(route.requestFocus, isFalse);

        pages.value = _page(
          kind,
          builder: (_) => _counter('Popup'),
          barrierColor: Colors.blue,
          requestFocus: true,
        );
        await tester.pumpAndSettle();

        expect(ModalRoute.of(tester.element(find.text('Popup'))), same(route));
        expect(route.barrierDismissible, isTrue);
        expect(route.barrierColor, Colors.blue);
        expect(route.requestFocus, isTrue);
      });
    }
  });

  group('Barrier actions', () {
    for (final kind in [
      _PopupKind.bottomSheet,
      _PopupKind.cupertinoDialog,
      _PopupKind.popup,
      _PopupKind.sheet,
    ]) {
      testWidgets('${kind.name} custom barrier action replaces dismissal', (
        tester,
      ) async {
        var firstCalls = 0;
        var latestCalls = 0;
        final pages = ValueNotifier<Page<void>?>(
          _page(
            kind,
            builder: (_) => _counter('Popup'),
            onBarrierTap: () => firstCalls++,
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(firstCalls, 1);
        expect(find.text('Popup'), findsOneWidget);

        pages.value = _page(
          kind,
          builder: (_) => _counter('Popup'),
          onBarrierTap: () => latestCalls++,
        );
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(firstCalls, 1);
        expect(latestCalls, 1);
        expect(find.text('Popup'), findsOneWidget);
      });

      testWidgets(
        '${kind.name} disabled barrier does not invoke its callback',
        (tester) async {
          var calls = 0;
          final pages = ValueNotifier<Page<void>?>(
            _page(
              kind,
              builder: (_) => _counter('Popup'),
              barrierDismissible: false,
              onBarrierTap: () => calls++,
            ),
          );
          addTearDown(pages.dispose);
          await _pumpPages(tester, pages);
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
          expect(calls, 0);
          expect(find.text('Popup'), findsOneWidget);
        },
      );
    }

    testWidgets('bottom sheet accessibility dismissal uses the custom action', (
      tester,
    ) async {
      var calls = 0;
      final pages = ValueNotifier<Page<void>?>(
        _page(
          _PopupKind.bottomSheet,
          builder: (_) => _counter('Popup'),
          onBarrierTap: () => calls++,
        ),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final barrier = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Dismiss Popup',
      );
      final node = tester.getSemantics(barrier);
      tester.binding.performSemanticsAction(
        SemanticsActionEvent(
          type: SemanticsAction.dismiss,
          nodeId: node.id,
          viewId: tester.view.viewId,
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Popup'), findsOneWidget);
    }, variant: const TargetPlatformVariant({TargetPlatform.android}));

    for (final kind in [_PopupKind.cupertinoDialog, _PopupKind.popup]) {
      testWidgets('${kind.name} hint-only barrier respects Page.canPop', (
        tester,
      ) async {
        final pops = <bool>[];
        final pages = ValueNotifier<Page<void>?>(
          _page(
            kind,
            builder: (_) => _counter('Popup'),
            canPop: false,
            barrierOnTapHint: 'Close popup',
            onPopInvoked: (didPop, result) => pops.add(didPop),
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(find.text('Popup'), findsOneWidget);
        expect(pops, [false]);

        pages.value = _page(
          kind,
          builder: (_) => _counter('Popup'),
          barrierOnTapHint: 'Close popup',
          onPopInvoked: (didPop, result) => pops.add(didPop),
        );
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(find.text('Popup'), findsNothing);
        expect(pops, [false, true]);
      });

      testWidgets('${kind.name} hint-only barrier respects PopScope', (
        tester,
      ) async {
        final pages = ValueNotifier<Page<void>?>(
          _page(
            kind,
            builder: (_) => PopScope(canPop: false, child: _counter('Popup')),
            barrierOnTapHint: 'Close popup',
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(find.text('Popup'), findsOneWidget);
      });
    }
  });

  group('Cupertino sheet dismissal', () {
    for (final scrollable in [false, true]) {
      for (final blocker in [
        'canPop',
        'enableDrag',
        'isDismissible',
        'PopScope',
      ]) {
        testWidgets(
          '$blocker blocks ${scrollable ? 'scroll-linked' : 'plain'} drag',
          (tester) async {
            final pages = ValueNotifier<Page<void>?>(
              CupertinoSheetPage<void>(
                key: const ValueKey('popup'),
                builder: scrollable
                    ? null
                    : (_) => PopScope(
                        canPop: blocker != 'PopScope',
                        child: const Center(child: Text('Sheet')),
                      ),
                scrollableBuilder: scrollable
                    ? (_, controller) => PopScope(
                        canPop: blocker != 'PopScope',
                        child: _sheetList(controller),
                      )
                    : null,
                canPop: blocker != 'canPop',
                enableDrag: blocker != 'enableDrag',
                isDismissible: blocker != 'isDismissible',
              ),
            );
            addTearDown(pages.dispose);
            await _pumpPages(tester, pages);
            final route = ModalRoute.of(tester.element(find.text('Sheet')))!;
            await _dragSheetDown(tester);
            expect(find.text('Sheet'), findsOneWidget);
            expect(route.animation!.value, 1);

            if (scrollable) {
              await tester.drag(find.byType(ListView), const Offset(0, -160));
              await tester.pumpAndSettle();
              final list = tester.widget<ListView>(find.byType(ListView));
              expect(list.controller!.offset, greaterThan(0));
            }
          },
        );
      }
    }

    testWidgets(
      'scroll-linked dismissal starts working after Page.canPop changes',
      (tester) async {
        final pages = ValueNotifier<Page<void>?>(
          CupertinoSheetPage<void>(
            key: const ValueKey('popup'),
            canPop: false,
            scrollableBuilder: (_, controller) => _sheetList(controller),
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final route = ModalRoute.of(tester.element(find.text('Sheet')));
        await _dragSheetDown(tester);
        expect(find.text('Sheet'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -160));
        await tester.pumpAndSettle();
        final previousOffset = tester
            .widget<ListView>(find.byType(ListView))
            .controller!
            .offset;
        expect(previousOffset, greaterThan(0));

        pages.value = CupertinoSheetPage<void>(
          key: const ValueKey('popup'),
          scrollableBuilder: (_, controller) => _sheetList(controller),
        );
        await tester.pumpAndSettle();
        expect(
          ModalRoute.of(tester.element(find.byType(ListView))),
          same(route),
        );
        final controller = tester
            .widget<ListView>(find.byType(ListView))
            .controller!;
        expect(controller.offset, closeTo(previousOffset, 0.001));
        controller.jumpTo(0);
        await tester.pumpAndSettle();
        await _dragSheetDown(tester);
        expect(find.text('Sheet'), findsNothing);
      },
    );

    testWidgets('scroll-linked dismissal follows live PopScope changes', (
      tester,
    ) async {
      final canPop = ValueNotifier(false);
      addTearDown(canPop.dispose);
      final pages = ValueNotifier<Page<void>?>(
        CupertinoSheetPage<void>(
          key: const ValueKey('popup'),
          scrollableBuilder: (_, controller) => ValueListenableBuilder<bool>(
            valueListenable: canPop,
            builder: (_, value, _) =>
                PopScope(canPop: value, child: _sheetList(controller)),
          ),
        ),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      await _dragSheetDown(tester);
      expect(find.text('Sheet'), findsOneWidget);

      canPop.value = true;
      await tester.pumpAndSettle();
      await _dragSheetDown(tester);
      expect(find.text('Sheet'), findsNothing);
    });

    testWidgets('constraints can limit sheet content width and height', (
      tester,
    ) async {
      final pages = ValueNotifier<Page<void>?>(
        CupertinoSheetPage<void>(
          builder: (_) => const SizedBox.expand(key: ValueKey('constrained')),
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 240),
        ),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      expect(
        tester.getSize(find.byKey(const ValueKey('constrained'))),
        const Size(320, 240),
      );
    });
  });

  group('Nested Cupertino sheet updates', () {
    testWidgets('updates nested content while preserving navigator and state', (
      tester,
    ) async {
      final nestedKey = GlobalKey<NavigatorState>();
      final pages = ValueNotifier<Page<void>?>(
        CupertinoSheetPage<void>(
          key: const ValueKey('popup'),
          useNestedNavigation: true,
          nestedNavigatorKey: nestedKey,
          builder: (_) => _counter('first'),
        ),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final navigator = nestedKey.currentState;
      final innerRoute = ModalRoute.of(tester.element(find.text('first')));
      final state = tester.state(find.byType(_CounterBody));
      await tester.tap(find.text('Increment'));
      await tester.pump();

      pages.value = CupertinoSheetPage<void>(
        key: const ValueKey('popup'),
        useNestedNavigation: true,
        nestedNavigatorKey: nestedKey,
        builder: (_) => _counter('second'),
      );
      await tester.pumpAndSettle();

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      expect(find.text('Count: 1'), findsOneWidget);
      expect(tester.state(find.byType(_CounterBody)), same(state));
      expect(nestedKey.currentState, same(navigator));
      expect(
        ModalRoute.of(tester.element(find.text('second'))),
        same(innerRoute),
      );
    });

    testWidgets('updates the nested scroll controller when canPop changes', (
      tester,
    ) async {
      final nestedKey = GlobalKey<NavigatorState>();
      CupertinoSheetPage<void> sheet(bool canPop) => CupertinoSheetPage<void>(
        key: const ValueKey('popup'),
        useNestedNavigation: true,
        nestedNavigatorKey: nestedKey,
        canPop: canPop,
        scrollableBuilder: (_, controller) => _sheetList(controller),
      );
      final pages = ValueNotifier<Page<void>?>(sheet(false));
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final navigator = nestedKey.currentState;
      final innerRoute = ModalRoute.of(tester.element(find.text('Sheet')));
      final controller = tester
          .widget<ListView>(find.byType(ListView))
          .controller;
      await _dragSheetDown(tester);
      expect(find.text('Sheet'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -160));
      await tester.pumpAndSettle();
      final previousOffset = controller!.offset;
      expect(previousOffset, greaterThan(0));

      pages.value = sheet(true);
      await tester.pumpAndSettle();
      expect(nestedKey.currentState, same(navigator));
      expect(
        ModalRoute.of(tester.element(find.byType(ListView))),
        same(innerRoute),
      );
      expect(
        tester.widget<ListView>(find.byType(ListView)).controller,
        isNot(same(controller)),
      );
      final latestController = tester
          .widget<ListView>(find.byType(ListView))
          .controller!;
      expect(latestController.offset, closeTo(previousOffset, 0.001));
      latestController.jumpTo(0);
      await tester.pumpAndSettle();
      await _dragSheetDown(tester);
      expect(find.text('Sheet'), findsNothing);
    });

    testWidgets('nested PopScope changes refresh outer scroll dismissal', (
      tester,
    ) async {
      final canPop = ValueNotifier(false);
      addTearDown(canPop.dispose);
      final pages = ValueNotifier<Page<void>?>(
        CupertinoSheetPage<void>(
          useNestedNavigation: true,
          scrollableBuilder: (_, controller) => ValueListenableBuilder<bool>(
            valueListenable: canPop,
            builder: (_, value, _) =>
                PopScope(canPop: value, child: _sheetList(controller)),
          ),
        ),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      await _dragSheetDown(tester);
      expect(find.text('Sheet'), findsOneWidget);
      canPop.value = true;
      await tester.pumpAndSettle();
      await _dragSheetDown(tester);
      expect(find.text('Sheet'), findsNothing);
    });
  });

  group('Material sheet dismissal guards', () {
    for (final blocker in ['Page.canPop', 'PopScope']) {
      testWidgets('$blocker toggles preserve existing form content state', (
        tester,
      ) async {
        final canPop = ValueNotifier(true);
        addTearDown(canPop.dispose);
        ModalBottomSheetPage<void> sheet(bool pageCanPop) =>
            ModalBottomSheetPage<void>(
              key: const ValueKey('popup'),
              canPop: blocker != 'Page.canPop' || pageCanPop,
              showDragHandle: true,
              builder: (_) => ValueListenableBuilder<bool>(
                valueListenable: canPop,
                builder: (_, value, _) => PopScope(
                  canPop: blocker != 'PopScope' || value,
                  child: _counter('Sheet'),
                ),
              ),
            );
        final pages = ValueNotifier<Page<void>?>(sheet(true));
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final state = tester.state(find.byType(_CounterBody));
        final route = ModalRoute.of(tester.element(find.text('Sheet')));
        await tester.tap(find.text('Increment'));
        await tester.pump();
        for (final allowed in [false, true]) {
          canPop.value = allowed;
          pages.value = sheet(allowed);
          await tester.pumpAndSettle();
          expect(find.text('Count: 1'), findsOneWidget);
          expect(tester.state(find.byType(_CounterBody)), same(state));
          expect(
            ModalRoute.of(tester.element(find.text('Sheet'))),
            same(route),
          );
          expect(
            tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
            allowed,
          );
        }
      });

      testWidgets('$blocker blocks content drag and minimum-extent dismissal', (
        tester,
      ) async {
        final pages = ValueNotifier<Page<void>?>(
          ModalBottomSheetPage<void>(
            builder: (_) => PopScope(
              canPop: blocker != 'PopScope',
              child: const SizedBox(
                height: 400,
                child: Center(child: Text('Sheet')),
              ),
            ),
            canPop: blocker != 'Page.canPop',
            showDragHandle: true,
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final route = ModalRoute.of(tester.element(find.text('Sheet')))!;
        final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
        expect(sheet.enableDrag, isFalse);
        expect(sheet.showDragHandle, isFalse);
        await tester.fling(find.text('Sheet'), const Offset(0, 350), 1200);
        await tester.pumpAndSettle();
        expect(find.text('Sheet'), findsOneWidget);
        expect(route.animation!.value, 1);

        _notifyMinimumExtent(tester.element(find.text('Sheet')));
        await tester.pumpAndSettle();
        expect(find.text('Sheet'), findsOneWidget);
      });

      testWidgets(
        '$blocker refreshes handle gestures and accessibility action',
        (tester) async {
          final canPop = ValueNotifier(false);
          addTearDown(canPop.dispose);
          ModalBottomSheetPage<void> sheet(bool pageCanPop) =>
              ModalBottomSheetPage<void>(
                key: const ValueKey('popup'),
                builder: (_) => ValueListenableBuilder<bool>(
                  valueListenable: canPop,
                  builder: (_, value, _) => PopScope(
                    canPop: blocker != 'PopScope' || value,
                    child: const SizedBox(
                      height: 400,
                      child: Center(child: Text('Sheet')),
                    ),
                  ),
                ),
                canPop: blocker != 'Page.canPop' || pageCanPop,
                // The SDK normally permits handle gestures even if content drag
                // is disabled. Keep that behavior when no pop guard is active.
                enableDrag: false,
                showDragHandle: true,
              );
          final pages = ValueNotifier<Page<void>?>(sheet(false));
          addTearDown(pages.dispose);
          await _pumpPages(tester, pages);
          final route = ModalRoute.of(tester.element(find.text('Sheet')));
          expect(
            tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
            isFalse,
          );

          canPop.value = true;
          pages.value = sheet(true);
          await tester.pumpAndSettle();
          expect(
            ModalRoute.of(tester.element(find.text('Sheet'))),
            same(route),
          );
          expect(
            tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
            isTrue,
          );
          final handle = find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.button == true,
          );
          expect(handle, findsOneWidget);
          final node = tester.getSemantics(handle);
          tester.binding.performSemanticsAction(
            SemanticsActionEvent(
              type: SemanticsAction.tap,
              nodeId: node.id,
              viewId: tester.view.viewId,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Sheet'), findsNothing);

          pages.value = sheet(true);
          await tester.pumpAndSettle();
          await tester.fling(handle, const Offset(0, 350), 1200);
          await tester.pumpAndSettle();
          expect(find.text('Sheet'), findsNothing);
        },
        variant: const TargetPlatformVariant({TargetPlatform.android}),
      );
    }

    testWidgets('live PopScope permits extent dismissal after it changes', (
      tester,
    ) async {
      final canPop = ValueNotifier(false);
      addTearDown(canPop.dispose);
      final pages = ValueNotifier<Page<void>?>(
        ModalBottomSheetPage<void>(
          builder: (_) => ValueListenableBuilder<bool>(
            valueListenable: canPop,
            builder: (_, value, _) => PopScope(
              canPop: value,
              child: const SizedBox(height: 400, child: Text('Sheet')),
            ),
          ),
        ),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      _notifyMinimumExtent(tester.element(find.text('Sheet')));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsOneWidget);
      canPop.value = true;
      await tester.pumpAndSettle();
      _notifyMinimumExtent(tester.element(find.text('Sheet')));
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsNothing);
    });
  });

  for (final kind in [_PopupKind.bottomSheet, _PopupKind.sheet]) {
    testWidgets('${kind.name} refreshes idle PopEntry changes', (tester) async {
      final pages = ValueNotifier<Page<void>?>(
        _page(kind, builder: (_) => _counter('Popup')),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final route = ModalRoute.of(tester.element(find.text('Popup')))!;
      final entry = _TestPopEntry();
      addTearDown(entry.canPopNotifier.dispose);
      route.registerPopEntry(entry);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);

      entry.canPopNotifier.value = false;
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpAndSettle();
      expect(
        kind == _PopupKind.sheet
            ? (route as CupertinoSheetRoute<void>).enableDrag
            : (route as ModalBottomSheetRoute<void>).enableDrag,
        isFalse,
      );

      entry.canPopNotifier.value = true;
      await tester.pumpAndSettle();
      expect(
        kind == _PopupKind.sheet
            ? (route as CupertinoSheetRoute<void>).enableDrag
            : (route as ModalBottomSheetRoute<void>).enableDrag,
        isTrue,
      );
      route.unregisterPopEntry(entry);
      await tester.pumpAndSettle();
    });
  }

  group('Route lifecycle options', () {
    testWidgets('Material dialog preserves content when SafeArea changes', (
      tester,
    ) async {
      DialogPage<void> dialog(bool safeArea) => DialogPage<void>(
        key: const ValueKey('popup'),
        builder: (_) => _counter('Popup'),
        useSafeArea: safeArea,
      );
      final pages = ValueNotifier<Page<void>?>(dialog(true));
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final state = tester.state(find.byType(_CounterBody));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      for (final safeArea in [false, true]) {
        pages.value = dialog(safeArea);
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(_CounterBody)), same(state));
        expect(find.text('Count: 1'), findsOneWidget);
      }
    });

    testWidgets('Cupertino sheet preserves content when wrappers change', (
      tester,
    ) async {
      CupertinoSheetPage<void> sheet(bool customized) =>
          CupertinoSheetPage<void>(
            key: const ValueKey('popup'),
            builder: (_) => _counter('Popup'),
            backgroundColor: customized ? Colors.white : null,
            shape: customized ? const RoundedRectangleBorder() : null,
            useSafeArea: customized,
            constraints: customized
                ? const BoxConstraints(maxWidth: 400, maxHeight: 300)
                : null,
          );
      final pages = ValueNotifier<Page<void>?>(sheet(false));
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final state = tester.state(find.byType(_CounterBody));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      for (final customized in [true, false]) {
        pages.value = sheet(customized);
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(_CounterBody)), same(state));
        expect(find.text('Count: 1'), findsOneWidget);
      }
    });

    testWidgets('bottom sheet replaces routes when its controller changes', (
      tester,
    ) async {
      final first = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
      );
      final second = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 300),
      );
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      ModalBottomSheetPage<void> sheet(AnimationController controller) =>
          ModalBottomSheetPage<void>(
            key: const ValueKey('popup'),
            builder: (_) => _counter('Popup'),
            transitionAnimationController: controller,
          );
      final pages = ValueNotifier<Page<void>?>(sheet(first));
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final route = ModalRoute.of(tester.element(find.text('Popup')));
      await tester.tap(find.text('Increment'));
      await tester.pump();
      pages.value = sheet(second);
      await tester.pumpAndSettle();
      expect(
        ModalRoute.of(tester.element(find.text('Popup'))),
        isNot(same(route)),
      );
      expect(find.text('Count: 0'), findsOneWidget);
      // The route does not dispose caller-owned controllers.
      first.value = 0.5;
      pages.value = null;
      await tester.pumpAndSettle();
      second.value = 0.5;
    });

    testWidgets('bottom sheet updates durations but replaces cached curves', (
      tester,
    ) async {
      ModalBottomSheetPage<void> sheet(AnimationStyle style) =>
          ModalBottomSheetPage<void>(
            key: const ValueKey('popup'),
            builder: (_) => _counter('Popup'),
            sheetAnimationStyle: style,
          );
      final pages = ValueNotifier<Page<void>?>(
        sheet(const AnimationStyle(duration: Duration(milliseconds: 300))),
      );
      addTearDown(pages.dispose);
      await _pumpPages(tester, pages);
      final route = ModalRoute.of(tester.element(find.text('Popup')))!;
      await tester.tap(find.text('Increment'));
      await tester.pump();
      pages.value = sheet(
        const AnimationStyle(duration: Duration(milliseconds: 500)),
      );
      await tester.pumpAndSettle();
      expect(ModalRoute.of(tester.element(find.text('Popup'))), same(route));
      expect(route.transitionDuration, const Duration(milliseconds: 500));
      expect(find.text('Count: 1'), findsOneWidget);

      pages.value = sheet(const AnimationStyle(curve: Curves.linear));
      await tester.pumpAndSettle();
      expect(
        ModalRoute.of(tester.element(find.text('Popup'))),
        isNot(same(route)),
      );
      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets(
      'Cupertino sheet replaces implicit gap but updates explicit gaps',
      (tester) async {
        CupertinoSheetPage<void> sheet(double? topGap) =>
            CupertinoSheetPage<void>(
              key: const ValueKey('popup'),
              builder: (_) => _counter('Popup'),
              topGap: topGap,
            );
        final pages = ValueNotifier<Page<void>?>(sheet(null));
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final original = ModalRoute.of(tester.element(find.text('Popup')));
        pages.value = sheet(0.1);
        await tester.pumpAndSettle();
        final explicit = ModalRoute.of(tester.element(find.text('Popup')))!;
        expect(explicit, isNot(same(original)));
        await tester.tap(find.text('Increment'));
        await tester.pump();
        pages.value = sheet(0.2);
        await tester.pumpAndSettle();
        expect(
          ModalRoute.of(tester.element(find.text('Popup'))),
          same(explicit),
        );
        expect((explicit as CupertinoSheetRoute<void>).topGap, 0.2);
        expect(find.text('Count: 1'), findsOneWidget);
      },
    );
  });

  group('SDK route options', () {
    for (final kind in [_PopupKind.dialog, _PopupKind.raw]) {
      testWidgets('${kind.name} forwards and updates fullscreenDialog', (
        tester,
      ) async {
        final pages = ValueNotifier<Page<void>?>(
          _page(kind, builder: (_) => _counter('Popup')),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final route = ModalRoute.of(tester.element(find.text('Popup')))!;
        expect(route.fullscreenDialog, isFalse);
        pages.value = _page(
          kind,
          builder: (_) => _counter('Popup'),
          fullscreenDialog: true,
        );
        await tester.pumpAndSettle();
        expect(ModalRoute.of(tester.element(find.text('Popup'))), same(route));
        expect(route.fullscreenDialog, isTrue);
      });
    }

    testWidgets(
      'Material dialog uses themed barrier color and closed focus loop',
      (tester) async {
        final pages = ValueNotifier<Page<void>?>(
          DialogPage<void>(builder: (_) => _counter('Popup')),
        );
        addTearDown(pages.dispose);
        await _pumpPages(
          tester,
          pages,
          theme: ThemeData(
            dialogTheme: const DialogThemeData(barrierColor: Colors.green),
          ),
        );
        final route = ModalRoute.of(tester.element(find.text('Popup')))!;
        expect(route.barrierColor, Colors.green);
        expect(route.traversalEdgeBehavior, TraversalEdgeBehavior.closedLoop);
      },
    );

    testWidgets('bottom sheet uses themed barrier color by default', (
      tester,
    ) async {
      final pages = ValueNotifier<Page<void>?>(
        ModalBottomSheetPage<void>(builder: (_) => _counter('Popup')),
      );
      addTearDown(pages.dispose);
      await _pumpPages(
        tester,
        pages,
        theme: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(
            modalBarrierColor: Colors.green,
          ),
        ),
      );
      final route = ModalRoute.of(tester.element(find.text('Popup')))!;
      expect(route.barrierColor, Colors.green);
      expect(route.barrierLabel, isNotNull);
    });

    for (final kind in [_PopupKind.dialog, _PopupKind.raw]) {
      testWidgets('${kind.name} applies changed focus policy to a new scope', (
        tester,
      ) async {
        Page<void> dialog(TraversalEdgeBehavior policy) =>
            kind == _PopupKind.dialog
            ? DialogPage<void>(
                key: const ValueKey('popup'),
                builder: (_) => _counter('Popup'),
                traversalEdgeBehavior: policy,
              )
            : RawDialogPage<void>(
                key: const ValueKey('popup'),
                pageBuilder: (_, _, _) => _counter('Popup'),
                barrierLabel: 'Dismiss',
                traversalEdgeBehavior: policy,
                directionalTraversalEdgeBehavior: policy,
              );
        final pages = ValueNotifier<Page<void>?>(
          dialog(TraversalEdgeBehavior.closedLoop),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        final previousRoute = ModalRoute.of(tester.element(find.text('Popup')));
        final previousScope = FocusScope.of(tester.element(find.text('Popup')));
        expect(
          previousScope.traversalEdgeBehavior,
          TraversalEdgeBehavior.closedLoop,
        );

        pages.value = dialog(TraversalEdgeBehavior.leaveFlutterView);
        await tester.pumpAndSettle();
        final context = tester.element(find.text('Popup'));
        expect(ModalRoute.of(context), isNot(same(previousRoute)));
        expect(FocusScope.of(context), isNot(same(previousScope)));
        expect(
          FocusScope.of(context).traversalEdgeBehavior,
          TraversalEdgeBehavior.leaveFlutterView,
        );
        if (kind == _PopupKind.raw) {
          expect(
            FocusScope.of(context).directionalTraversalEdgeBehavior,
            TraversalEdgeBehavior.leaveFlutterView,
          );
        }
      });
    }

    for (final kind in [_PopupKind.cupertinoDialog, _PopupKind.popup]) {
      testWidgets(
        '${kind.name} resolves current colors using captured theme traits',
        (tester) async {
          const color = CupertinoDynamicColor.withBrightness(
            color: Colors.red,
            darkColor: Colors.blue,
          );
          final pages = ValueNotifier<Page<void>?>(
            _page(kind, builder: (_) => _counter('Popup'), barrierColor: color),
          );
          addTearDown(pages.dispose);
          await _pumpPages(tester, pages, theme: ThemeData.light());
          final route = ModalRoute.of(tester.element(find.text('Popup')))!;
          _expectSameColor(route.barrierColor, Colors.red);
          await _pumpPages(tester, pages, theme: ThemeData.dark());
          expect(
            ModalRoute.of(tester.element(find.text('Popup'))),
            same(route),
          );
          _expectSameColor(route.barrierColor, Colors.red);
          pages.value = _page(
            kind,
            builder: (_) => _counter('Popup'),
            barrierColor: const CupertinoDynamicColor.withBrightness(
              color: Colors.green,
              darkColor: Colors.yellow,
            ),
          );
          await tester.pumpAndSettle();
          _expectSameColor(route.barrierColor, Colors.green);
        },
      );
    }

    for (final kind in [_PopupKind.cupertinoDialog, _PopupKind.popup]) {
      for (final brightness in Brightness.values) {
        for (final contrast in [false, true]) {
          for (final level in CupertinoUserInterfaceLevelData.values) {
            testWidgets(
              '${kind.name} preserves local $brightness contrast=$contrast $level after caller unmounts',
              (tester) async {
                const color = CupertinoDynamicColor(
                  color: Colors.red,
                  darkColor: Colors.blue,
                  highContrastColor: Colors.green,
                  darkHighContrastColor: Colors.yellow,
                  elevatedColor: Colors.orange,
                  darkElevatedColor: Colors.purple,
                  highContrastElevatedColor: Colors.pink,
                  darkHighContrastElevatedColor: Colors.brown,
                );
                final showCaller = ValueNotifier(true);
                addTearDown(showCaller.dispose);
                late BuildContext context;
                await tester.pumpWidget(
                  MaterialApp(
                    theme: ThemeData.light(),
                    home: ValueListenableBuilder<bool>(
                      valueListenable: showCaller,
                      builder: (_, show, _) => show
                          ? CupertinoTheme(
                              data: CupertinoThemeData(brightness: brightness),
                              child: MediaQuery(
                                data: MediaQueryData(highContrast: contrast),
                                child: CupertinoUserInterfaceLevel(
                                  data: level,
                                  child: Builder(
                                    builder: (value) {
                                      context = value;
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                );
                final expected = CupertinoDynamicColor.resolve(color, context);
                final route = _page(
                  kind,
                  builder: (_) => _counter('Popup'),
                  barrierColor: color,
                ).createRoute(context) as ModalRoute<void>;
                Navigator.of(context).push(route);
                await tester.pumpAndSettle();
                _expectSameColor(route.barrierColor, expected);
                showCaller.value = false;
                await tester.pumpAndSettle();
                expect(context.mounted, isFalse);
                _expectSameColor(route.barrierColor, expected);
                route.navigator!.pop();
                await tester.pumpAndSettle();
              },
            );
          }
        }
      }

      testWidgets('${kind.name} preserves a nested resolved dynamic variant', (
        tester,
      ) async {
        late BuildContext context;
        await tester.pumpWidget(
          MaterialApp(
            home: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: Builder(
                builder: (value) {
                  context = value;
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        final nested = CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Colors.red,
            darkColor: Colors.blue,
          ),
          context,
        );
        final color = CupertinoDynamicColor.withBrightness(
          color: nested,
          darkColor: nested,
        );
        final expected = CupertinoDynamicColor.resolve(color, context);
        final route = _page(
          kind,
          builder: (_) => _counter('Popup'),
          barrierColor: color,
        ).createRoute(context) as ModalRoute<void>;
        Navigator.of(context).push(route);
        await tester.pumpAndSettle();
        _expectSameColor(route.barrierColor, expected);
        route.navigator!.pop();
        await tester.pumpAndSettle();
      });
    }

    testWidgets(
      'Cupertino popup resolves its default barrier and preserves null',
      (tester) async {
        final pages = ValueNotifier<Page<void>?>(
          CupertinoModalPopupPage<void>(
            key: const ValueKey('popup'),
            builder: (_) => _counter('Popup'),
          ),
        );
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages, theme: ThemeData.dark());
        final route = ModalRoute.of(tester.element(find.text('Popup')))!;
        _expectSameColor(
          route.barrierColor,
          CupertinoDynamicColor.resolve(
            kCupertinoModalBarrierColor,
            route.navigator!.context,
          ),
        );
        pages.value = CupertinoModalPopupPage<void>(
          key: const ValueKey('popup'),
          builder: (_) => _counter('Popup'),
          barrierColor: null,
        );
        await tester.pumpAndSettle();
        expect(route.barrierColor, isNull);
      },
    );

    for (final duration in [Duration.zero, const Duration(seconds: 1)]) {
      testWidgets('Cupertino dialog honors custom duration $duration', (
        tester,
      ) async {
        final pages = ValueNotifier<Page<void>?>(null);
        addTearDown(pages.dispose);
        await _pumpPages(tester, pages);
        pages.value = CupertinoDialogPage<void>(
          builder: (_) => _counter('Popup'),
          transitionDuration: duration,
        );
        await tester.pump();
        final route = ModalRoute.of(tester.element(find.text('Popup')))!;
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          route.animation!.value,
          duration == Duration.zero ? 1 : closeTo(0.25, 0.001),
        );
        await tester.pumpAndSettle();
        route.navigator!.pop();
        await tester.pump();
        if (duration != Duration.zero) {
          await tester.pump(const Duration(milliseconds: 250));
          expect(route.animation!.value, closeTo(0.75, 0.001));
        }
        await tester.pumpAndSettle();
        expect(find.text('Popup'), findsNothing);
      });
    }

    testWidgets(
      'context helpers forward pop callbacks and fullscreen options',
      (tester) async {
        final pops = <bool>[];
        late BuildContext context;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (value) {
                context = value;
                return const SizedBox();
              },
            ),
          ),
        );
        final dialog = context.createDialogPage<void>(
          builder: (_) => const SizedBox(),
          canPop: false,
          onPopInvoked: (didPop, result) => pops.add(didPop),
          fullscreenDialog: true,
        );
        expect(dialog.canPop, isFalse);
        expect(
          (dialog.createRoute(context) as DialogRoute<void>).fullscreenDialog,
          isTrue,
        );
        dialog.onPopInvoked(false, null);
        final raw = context.createRawDialogPage<void>(
          pageBuilder: (_, _, _) => const SizedBox(),
          barrierLabel: 'Dismiss',
          canPop: false,
          onPopInvoked: (didPop, result) => pops.add(didPop),
          fullscreenDialog: true,
        );
        expect(raw.canPop, isFalse);
        expect(
          (raw.createRoute(context) as RawDialogRoute<void>).fullscreenDialog,
          isTrue,
        );
        raw.onPopInvoked(false, null);
        final otherPages = <Page<void>>[
          context.createModalBottomSheetPage<void>(
            builder: (_) => const SizedBox(),
            canPop: false,
            onPopInvoked: (didPop, result) => pops.add(didPop),
          ),
          context.createCupertinoDialogPage<void>(
            builder: (_) => const SizedBox(),
            canPop: false,
            onPopInvoked: (didPop, result) => pops.add(didPop),
          ),
          context.createCupertinoModalPopupPage<void>(
            builder: (_) => const SizedBox(),
            canPop: false,
            onPopInvoked: (didPop, result) => pops.add(didPop),
          ),
          context.createCupertinoSheetPage<void>(
            builder: (_) => const SizedBox(),
            canPop: false,
            onPopInvoked: (didPop, result) => pops.add(didPop),
          ),
        ];
        for (final page in otherPages) {
          expect(page.canPop, isFalse);
          page.onPopInvoked(false, null);
        }
        expect(pops, List.filled(6, false));
      },
    );

    for (final kind in _PopupKind.values) {
      testWidgets(
        '${kind.name} navigator helper forwards pop policy and callbacks',
        (tester) async {
          late NavigatorState navigator;
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  navigator = Navigator.of(context);
                  return const SizedBox();
                },
              ),
            ),
          );
          final pops = <bool>[];
          void onPop(bool didPop, void result) => pops.add(didPop);
          final result = switch (kind) {
            _PopupKind.dialog => navigator.showDeclarativeDialog<void>(
              builder: (_) => _counter('Popup'),
              canPop: false,
              onPopInvoked: onPop,
              fullscreenDialog: true,
            ),
            _PopupKind.bottomSheet =>
              navigator.showDeclarativeModalBottomSheet<void>(
                builder: (_) => _counter('Popup'),
                canPop: false,
                onPopInvoked: onPop,
              ),
            _PopupKind.cupertinoDialog =>
              navigator.showDeclarativeCupertinoDialog<void>(
                builder: (_) => _counter('Popup'),
                canPop: false,
                onPopInvoked: onPop,
              ),
            _PopupKind.popup => navigator.pushCupertinoModalPopup<void>(
              builder: (_) => _counter('Popup'),
              canPop: false,
              onPopInvoked: onPop,
            ),
            _PopupKind.sheet => navigator.showCupertinoSheet<void>(
              builder: (_) => _counter('Popup'),
              canPop: false,
              onPopInvoked: onPop,
            ),
            _PopupKind.raw => navigator.showRawDialog<void>(
              pageBuilder: (_, _, _) => _counter('Popup'),
              barrierLabel: 'Dismiss',
              canPop: false,
              onPopInvoked: onPop,
              fullscreenDialog: true,
            ),
          };
          await tester.pumpAndSettle();
          final route = ModalRoute.of(tester.element(find.text('Popup')))!;
          expect(route.popDisposition, RoutePopDisposition.doNotPop);
          if (kind == _PopupKind.dialog || kind == _PopupKind.raw) {
            expect(route.fullscreenDialog, isTrue);
          }
          await navigator.maybePop();
          await tester.pumpAndSettle();
          expect(find.text('Popup'), findsOneWidget);
          expect(pops, [false]);
          navigator.pop();
          await tester.pumpAndSettle();
          await result;
          expect(pops, [false, true]);
        },
      );
    }
  });
}

Page<void> _page(
  _PopupKind kind, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool? requestFocus,
  VoidCallback? onBarrierTap,
  String? barrierOnTapHint,
  bool canPop = true,
  PopInvokedWithResultCallback<void>? onPopInvoked,
  bool fullscreenDialog = false,
}) {
  void onPop(bool didPop, void result) => onPopInvoked?.call(didPop, result);
  return switch (kind) {
    _PopupKind.dialog => DialogPage<void>(
      key: const ValueKey('popup'),
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Dismiss Popup',
      requestFocus: requestFocus,
      canPop: canPop,
      onPopInvoked: onPop,
      fullscreenDialog: fullscreenDialog,
    ),
    _PopupKind.bottomSheet => ModalBottomSheetPage<void>(
      key: const ValueKey('popup'),
      builder: builder,
      isDismissible: barrierDismissible,
      modalBarrierColor: barrierColor,
      barrierLabel: 'Dismiss Popup',
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      canPop: canPop,
      onPopInvoked: onPop,
    ),
    _PopupKind.cupertinoDialog => CupertinoDialogPage<void>(
      key: const ValueKey('popup'),
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Dismiss Popup',
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      canPop: canPop,
      onPopInvoked: onPop,
    ),
    _PopupKind.popup => CupertinoModalPopupPage<void>(
      key: const ValueKey('popup'),
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Dismiss Popup',
      requestFocus: requestFocus,
      onBarrierTap: onBarrierTap,
      barrierOnTapHint: barrierOnTapHint,
      canPop: canPop,
      onPopInvoked: onPop,
    ),
    _PopupKind.sheet => CupertinoSheetPage<void>(
      key: const ValueKey('popup'),
      builder: builder,
      isDismissible: barrierDismissible,
      onBarrierTap: onBarrierTap,
      canPop: canPop,
      onPopInvoked: onPop,
    ),
    _PopupKind.raw => RawDialogPage<void>(
      key: const ValueKey('popup'),
      pageBuilder: (context, _, _) => builder(context),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Dismiss Popup',
      requestFocus: requestFocus,
      canPop: canPop,
      onPopInvoked: onPop,
      fullscreenDialog: fullscreenDialog,
    ),
  };
}

Future<void> _pumpPages(
  WidgetTester tester,
  ValueNotifier<Page<void>?> pages, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: ValueListenableBuilder<Page<void>?>(
        valueListenable: pages,
        builder: (_, page, _) => Navigator(
          pages: [
            const MaterialPage<void>(
              key: ValueKey('home'),
              child: Scaffold(body: Text('Home')),
            ),
            ?page,
          ],
          onDidRemovePage: (page) {
            if (identical(page, pages.value)) {
              pages.value = null;
            }
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _counter(String label) => Center(
  child: Material(
    child: SizedBox(width: 240, height: 160, child: _CounterBody(label)),
  ),
);

Widget _sheetList(ScrollController controller) => ListView(
  controller: controller,
  children: [
    const Text('Sheet'),
    for (var index = 0; index < 50; index++)
      SizedBox(height: 40, child: Text('Item $index')),
  ],
);

Future<void> _dragSheetDown(WidgetTester tester) async {
  await tester.timedDragFrom(
    const Offset(400, 160),
    const Offset(0, 350),
    const Duration(milliseconds: 600),
  );
  await tester.pumpAndSettle();
}

void _notifyMinimumExtent(BuildContext context) {
  DraggableScrollableNotification(
    extent: 0.2,
    minExtent: 0.2,
    maxExtent: 1,
    initialExtent: 0.6,
    context: context,
  ).dispatch(context);
}

void _expectSameColor(Color? actual, Color expected) {
  expect(actual, isNotNull);
  expect(actual!.a, expected.a);
  expect(actual.r, expected.r);
  expect(actual.g, expected.g);
  expect(actual.b, expected.b);
  expect(actual.colorSpace, expected.colorSpace);
}

class _CounterBody extends StatefulWidget {
  const _CounterBody(this.label);

  final String label;

  @override
  State<_CounterBody> createState() => _CounterBodyState();
}

class _CounterBodyState extends State<_CounterBody> {
  var _count = 0;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(widget.label),
      Text('Count: $_count'),
      TextButton(
        onPressed: () => setState(() => _count++),
        child: const Text('Increment'),
      ),
    ],
  );
}

class _TestPopEntry extends PopEntry<void> {
  @override
  final ValueNotifier<bool> canPopNotifier = ValueNotifier(true);
}
