import 'package:example/main.dart';
import 'package:example/navigator_2/app_router_delegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final strategy in RoutingType.values) {
    testWidgets('${strategy.title}: popup results, dismissal, and back', (
      tester,
    ) async {
      await tester.pumpWidget(const RoutingSelectorApp());
      await tester.pumpAndSettle();
      await _selectRouting(tester, strategy);
      final prefix = strategy == RoutingType.navigator1 ? 'Push ' : 'Show ';
      final dialog = strategy == RoutingType.navigator1
          ? 'DialogPage'
          : 'Dialog';
      final bottomSheet = strategy == RoutingType.navigator1
          ? 'ModalBottomSheetPage'
          : 'Bottom Sheet';
      final cupertino = strategy == RoutingType.navigator1
          ? 'CupertinoDialogPage'
          : 'Cupertino Dialog';

      await _tapVisible(tester, '$prefix$dialog');
      expect(find.text('Sample Dialog'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Confirmed'), findsOneWidget);

      await _tapVisible(tester, '$prefix$bottomSheet');
      expect(find.text('Sample Bottom Sheet'), findsOneWidget);
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(find.text('Option 2'), findsOneWidget);

      await _tapVisible(tester, '$prefix$cupertino');
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('OK Pressed'), findsOneWidget);

      if (strategy == RoutingType.navigator2) {
        await _tapVisible(tester, 'Show Scrollable Cupertino Sheet');
        expect(find.text('Scrollable Sheet'), findsOneWidget);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Closed via Done'), findsOneWidget);
        await _tapVisible(tester, '$prefix$cupertino');
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      await _tapVisible(tester, '$prefix$dialog');
      await tester.tapAt(const Offset(12, 350));
      await tester.pumpAndSettle();
      expect(find.text('Sample Dialog'), findsNothing);
      expect(find.text('OK Pressed'), findsOneWidget);

      await _tapVisible(tester, '$prefix$cupertino');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      expect(find.text('OK Pressed'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('switch routing with a pending popup and reopen each strategy', (
    tester,
  ) async {
    await tester.pumpWidget(const RoutingSelectorApp());
    await tester.pumpAndSettle();
    await _tapVisible(tester, 'Show Dialog');
    await _selectRouting(tester, RoutingType.goRouter);
    expect(find.text('Sample Dialog'), findsNothing);
    await _tapVisible(tester, 'Show Dialog');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmed'), findsOneWidget);
    await _selectRouting(tester, RoutingType.navigator2);
    await _tapVisible(tester, 'Show Dialog');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelled'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Navigator 2 replacement preserves the new route and futures', (
    tester,
  ) async {
    final delegate = AppRouterDelegate();
    await tester.pumpWidget(
      MaterialApp(home: Router(routerDelegate: delegate)),
    );
    await tester.pumpAndSettle();
    final dialogResult = delegate.showDialog();
    expect(delegate.showDialog(), same(dialogResult));
    await tester.pumpAndSettle();
    final sheetResult = delegate.showBottomSheet();
    await tester.pumpAndSettle();
    expect(await dialogResult.timeout(const Duration(seconds: 10)), isNull);
    expect(find.text('Sample Bottom Sheet'), findsOneWidget);
    await tester.tap(find.text('Option 3'));
    await tester.pumpAndSettle();
    expect(await sheetResult, 'Option 3');
    expect(delegate.currentConfiguration?.route, AppRoute.home);
    await tester.pumpWidget(const SizedBox());
    delegate.dispose();
  });

  for (final kind in _PopupKind.values) {
    testWidgets(
      '${kind.name}: same-key content updates retain route and state',
      (tester) async {
        final config = ValueNotifier(_PopupConfig(kind: kind));
        await tester.pumpWidget(_PopupHarness(config: config));
        await tester.pumpAndSettle();
        final initialRoute = ModalRoute.of(
          tester.element(find.byKey(const ValueKey('counter'))),
        );
        await tester.tap(find.text('Increment'));
        await tester.pumpAndSettle();
        config.value = _PopupConfig(kind: kind, label: 'Updated');
        await tester.pumpAndSettle();
        expect(find.text('Updated: 1'), findsOneWidget);
        expect(
          ModalRoute.of(tester.element(find.byKey(const ValueKey('counter')))),
          same(initialRoute),
        );
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Harness home'), findsOneWidget);
        expect(find.byKey(const ValueKey('counter')), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        config.dispose();
      },
    );
  }

  testWidgets('custom Material sheet barrier callback replaces dismissal', (
    tester,
  ) async {
    var barrierTaps = 0;
    final config = ValueNotifier(
      _PopupConfig(
        kind: _PopupKind.bottomSheet,
        onBarrierTap: () => barrierTaps++,
      ),
    );
    await tester.pumpWidget(_PopupHarness(config: config));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(12, 100));
    await tester.pumpAndSettle();
    expect(barrierTaps, 1);
    expect(find.text('Original: 0'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    config.dispose();
  });

  for (final kind in [_PopupKind.cupertinoDialog, _PopupKind.cupertinoPopup]) {
    testWidgets('${kind.name}: hint-only barrier honors both pop gates', (
      tester,
    ) async {
      final attempts = <bool>[];
      final config = ValueNotifier(
        _PopupConfig(kind: kind, pageCanPop: false, onPop: attempts.add),
      );
      await tester.pumpWidget(_PopupHarness(config: config));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(12, 100));
      await tester.pumpAndSettle();
      expect(find.text('Original: 0'), findsOneWidget);
      expect(attempts, [false]);
      config.value = _PopupConfig(
        kind: kind,
        scopeCanPop: false,
        onPop: attempts.add,
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(12, 100));
      await tester.pumpAndSettle();
      expect(find.text('Original: 0'), findsOneWidget);
      expect(attempts, [false, false]);
      config.value = _PopupConfig(kind: kind, onPop: attempts.add);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(12, 100));
      await tester.pumpAndSettle();
      expect(find.text('Original: 0'), findsNothing);
      expect(attempts, [false, false, true]);
      await tester.pumpWidget(const SizedBox());
      config.dispose();
    });
  }

  testWidgets('Material sheet content and handle drag honor pop gates', (
    tester,
  ) async {
    final config = ValueNotifier(
      const _PopupConfig(kind: _PopupKind.bottomSheet, pageCanPop: false),
    );
    await tester.pumpWidget(_PopupHarness(config: config));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Increment'));
    await tester.pumpAndSettle();
    await _dragSheet(tester);
    await _dragMaterialHandle(tester);
    expect(find.text('Original: 1'), findsOneWidget);
    config.value = const _PopupConfig(
      kind: _PopupKind.bottomSheet,
      scopeCanPop: false,
    );
    await tester.pumpAndSettle();
    await _dragSheet(tester);
    await _dragMaterialHandle(tester);
    expect(find.text('Original: 1'), findsOneWidget);
    config.value = const _PopupConfig(kind: _PopupKind.bottomSheet);
    await tester.pumpAndSettle();
    await _dragMaterialHandle(tester);
    expect(find.text('Original: 1'), findsNothing);
    expect(find.text('Harness home'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    config.dispose();
  });

  testWidgets('nested Cupertino sheet updates content and live pop gates', (
    tester,
  ) async {
    final config = ValueNotifier(
      const _PopupConfig(
        kind: _PopupKind.cupertinoSheet,
        nested: true,
        scrollable: true,
        pageCanPop: false,
      ),
    );
    await tester.pumpWidget(_PopupHarness(config: config));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Increment'));
    await tester.pumpAndSettle();
    final nestedRoute = ModalRoute.of(
      tester.element(find.byKey(const ValueKey('counter'))),
    );
    await _dragSheet(tester);
    expect(find.text('Original: 1'), findsOneWidget);
    config.value = const _PopupConfig(
      kind: _PopupKind.cupertinoSheet,
      nested: true,
      scrollable: true,
      scopeCanPop: false,
      label: 'Updated',
    );
    await tester.pumpAndSettle();
    expect(find.text('Updated: 1'), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byKey(const ValueKey('counter')))),
      same(nestedRoute),
    );
    await _dragSheet(tester);
    expect(find.text('Updated: 1'), findsOneWidget);
    config.value = const _PopupConfig(
      kind: _PopupKind.cupertinoSheet,
      nested: true,
      scrollable: true,
      label: 'Updated',
    );
    await tester.pumpAndSettle();
    await _dragSheet(tester);
    expect(find.text('Updated: 1'), findsNothing);
    expect(find.text('Harness home'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    config.dispose();
  });

  testWidgets(
    'Cupertino sheet pop-gate controller swaps preserve scroll offset',
    (tester) async {
      final config = ValueNotifier(
        const _PopupConfig(
          kind: _PopupKind.cupertinoSheet,
          scrollable: true,
          pageCanPop: false,
        ),
      );
      await tester.pumpWidget(_PopupHarness(config: config));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      double scrollOffset() => tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            ),
          )
          .position
          .pixels;
      final offset = scrollOffset();
      expect(offset, greaterThan(100));
      config.value = const _PopupConfig(
        kind: _PopupKind.cupertinoSheet,
        scrollable: true,
      );
      await tester.pumpAndSettle();
      expect(scrollOffset(), closeTo(offset, 0.5));
      config.value = const _PopupConfig(
        kind: _PopupKind.cupertinoSheet,
        scrollable: true,
        scopeCanPop: false,
      );
      await tester.pumpAndSettle();
      expect(scrollOffset(), closeTo(offset, 0.5));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      config.dispose();
    },
  );

  for (final scrollable in [false, true]) {
    testWidgets(
      'Cupertino sheet drag respects pop gates, scrollable=$scrollable',
      (tester) async {
        final config = ValueNotifier(
          _PopupConfig(
            kind: _PopupKind.cupertinoSheet,
            pageCanPop: false,
            scrollable: scrollable,
          ),
        );
        await tester.pumpWidget(_PopupHarness(config: config));
        await tester.pumpAndSettle();
        await _dragSheet(tester);
        expect(find.text('Original: 0'), findsOneWidget);
        config.value = _PopupConfig(
          kind: _PopupKind.cupertinoSheet,
          scopeCanPop: false,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();
        await _dragSheet(tester);
        expect(find.text('Original: 0'), findsOneWidget);
        config.value = _PopupConfig(
          kind: _PopupKind.cupertinoSheet,
          scrollable: scrollable,
        );
        await tester.pumpAndSettle();
        await _dragSheet(tester);
        expect(find.text('Original: 0'), findsNothing);
        expect(find.text('Harness home'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        config.dispose();
      },
    );
  }
}

Future<void> _selectRouting(WidgetTester tester, RoutingType strategy) async {
  final dropdown = tester.widget<DropdownButton<RoutingType>>(
    find.byType(DropdownButton<RoutingType>),
  );
  if (dropdown.value == strategy) return;
  await tester.tap(find.byType(DropdownButton<RoutingType>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(strategy.title).last);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _dragSheet(WidgetTester tester) async {
  final content = find.byKey(const ValueKey('counter'));
  await tester.flingFrom(
    tester.getTopLeft(content) + const Offset(40, 20),
    const Offset(0, 600),
    1400,
  );
  await tester.pumpAndSettle();
}

Future<void> _dragMaterialHandle(WidgetTester tester) async {
  final sheet = find.byType(BottomSheet);
  final origin = tester.getTopLeft(sheet);
  final size = tester.getSize(sheet);
  await tester.flingFrom(
    origin + Offset(size.width / 2, 12),
    const Offset(0, 600),
    1400,
  );
  await tester.pumpAndSettle();
}

enum _PopupKind {
  dialog,
  bottomSheet,
  cupertinoDialog,
  cupertinoPopup,
  cupertinoSheet,
  rawDialog,
}

class _PopupConfig {
  const _PopupConfig({
    required this.kind,
    this.label = 'Original',
    this.pageCanPop = true,
    this.scopeCanPop = true,
    this.scrollable = false,
    this.nested = false,
    this.onBarrierTap,
    this.onPop,
  });

  final _PopupKind kind;
  final String label;
  final bool pageCanPop;
  final bool scopeCanPop;
  final bool scrollable;
  final bool nested;
  final VoidCallback? onBarrierTap;
  final ValueChanged<bool>? onPop;

  Widget content(BuildContext context) => PopScope<String>(
    canPop: scopeCanPop,
    child: _Counter(key: const ValueKey('counter'), label: label),
  );

  Page<String> page() {
    const key = ValueKey('popup');
    void onPopInvoked(bool didPop, String? result) => onPop?.call(didPop);
    switch (kind) {
      case _PopupKind.dialog:
        return DialogPage<String>(
          key: key,
          canPop: pageCanPop,
          onPopInvoked: onPopInvoked,
          builder: (context) => Center(child: content(context)),
        );
      case _PopupKind.bottomSheet:
        return ModalBottomSheetPage<String>(
          key: key,
          canPop: pageCanPop,
          onPopInvoked: onPopInvoked,
          onBarrierTap: onBarrierTap,
          showDragHandle: true,
          builder: content,
        );
      case _PopupKind.cupertinoDialog:
        return CupertinoDialogPage<String>(
          key: key,
          canPop: pageCanPop,
          onPopInvoked: onPopInvoked,
          barrierDismissible: true,
          barrierOnTapHint: 'Dismiss test popup',
          builder: (context) => Center(child: content(context)),
        );
      case _PopupKind.cupertinoPopup:
        return CupertinoModalPopupPage<String>(
          key: key,
          canPop: pageCanPop,
          onPopInvoked: onPopInvoked,
          barrierOnTapHint: 'Dismiss test popup',
          builder: content,
        );
      case _PopupKind.cupertinoSheet:
        return CupertinoSheetPage<String>(
          key: key,
          canPop: pageCanPop,
          onPopInvoked: onPopInvoked,
          useNestedNavigation: nested,
          builder: scrollable ? null : content,
          scrollableBuilder: scrollable
              ? (context, controller) => ListView(
                  controller: controller,
                  children: [
                    content(context),
                    for (var index = 0; index < 40; index++)
                      CupertinoListTile(title: Text('Row $index')),
                  ],
                )
              : null,
        );
      case _PopupKind.rawDialog:
        return RawDialogPage<String>(
          key: key,
          canPop: pageCanPop,
          onPopInvoked: onPopInvoked,
          barrierLabel: 'Dismiss',
          pageBuilder: (context, animation, secondaryAnimation) =>
              Center(child: content(context)),
        );
    }
  }
}

class _PopupHarness extends StatefulWidget {
  const _PopupHarness({required this.config});

  final ValueNotifier<_PopupConfig> config;

  @override
  State<_PopupHarness> createState() => _PopupHarnessState();
}

class _PopupHarnessState extends State<_PopupHarness> {
  var _showPopup = true;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: ValueListenableBuilder<_PopupConfig>(
      valueListenable: widget.config,
      builder: (context, config, child) => Navigator(
        pages: [
          const MaterialPage<void>(
            child: Scaffold(body: Center(child: Text('Harness home'))),
          ),
          if (_showPopup) config.page(),
        ],
        onDidRemovePage: (page) => setState(() => _showPopup = false),
      ),
    ),
  );
}

class _Counter extends StatefulWidget {
  const _Counter({super.key, required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var _count = 0;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    child: SizedBox(
      width: 300,
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${widget.label}: $_count'),
          TextButton(
            onPressed: () => setState(() => _count++),
            child: const Text('Increment'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('Closed'),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}
