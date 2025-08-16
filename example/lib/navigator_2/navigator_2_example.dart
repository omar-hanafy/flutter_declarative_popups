import 'package:flutter/material.dart';
import '../shared/popup_demo_widget.dart';
import '../shared/result_display.dart';
import 'app_router_delegate.dart';
import 'route_information_parser.dart';

class Navigator2Example extends StatefulWidget {
  const Navigator2Example({super.key});

  @override
  State<Navigator2Example> createState() => _Navigator2ExampleState();
}

class _Navigator2ExampleState extends State<Navigator2Example> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class Navigator2HomePage extends StatefulWidget {
  final AppRouterDelegate routerDelegate;

  const Navigator2HomePage({
    super.key,
    required this.routerDelegate,
  });

  @override
  State<Navigator2HomePage> createState() => _Navigator2HomePageState();
}

class _Navigator2HomePageState extends State<Navigator2HomePage> {
  String? _lastResult;

  void _handleResult(String? result) {
    if (result != null) {
      setState(() => _lastResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResultDisplay(
            result: _lastResult,
            onClear: () => setState(() => _lastResult = null),
          ),
          if (_lastResult != null) const SizedBox(height: 16),
          PopupDemoSection(
            title: 'Material Design Popups',
            icon: Icons.android,
            buttons: [
              PopupDemoButton(
                label: 'Show Dialog',
                icon: Icons.chat_bubble_outline,
                description: 'DialogPage with path: /dialog',
                onPressed: () async {
                  widget.routerDelegate.showDialog();
                  final result =
                      await widget.routerDelegate.dialogCompleter.future;
                  _handleResult(result);
                },
              ),
              PopupDemoButton(
                label: 'Show Bottom Sheet',
                icon: Icons.vertical_align_bottom,
                description: 'ModalBottomSheetPage with path: /bottom-sheet',
                onPressed: () async {
                  widget.routerDelegate.showBottomSheet();
                  final result =
                      await widget.routerDelegate.bottomSheetCompleter.future;
                  _handleResult(result);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          PopupDemoSection(
            title: 'Cupertino (iOS Style) Popups',
            icon: Icons.apple,
            buttons: [
              PopupDemoButton(
                label: 'Show Cupertino Dialog',
                icon: Icons.chat_bubble_outline,
                description: 'CupertinoDialogPage with path: /cupertino-dialog',
                onPressed: () async {
                  widget.routerDelegate.showCupertinoDialog();
                  final result = await widget
                      .routerDelegate.cupertinoDialogCompleter.future;
                  _handleResult(result);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Navigator 2.0 Implementation',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This example uses direct implementation of RouterDelegate and RouteInformationParser. '
                    'Each popup is a page in the navigation stack with its own path.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
