import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
import '../shared/popup_demo_widget.dart';
import '../shared/result_display.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const GoRouterHomePage(),
        routes: [
          // Dialog route
          GoRoute(
            path: 'dialog',
            pageBuilder: (context, state) => DialogPage<String>(
              key: state.pageKey,
              builder: (context) => const SampleDialog(),
            ),
          ),
          // Bottom sheet route
          GoRoute(
            path: 'bottom-sheet',
            pageBuilder: (context, state) => ModalBottomSheetPage<String>(
              key: state.pageKey,
              builder: (context) => const SampleBottomSheet(),
              showDragHandle: true,
            ),
          ),
          // Cupertino dialog route
          GoRoute(
            path: 'cupertino-dialog',
            pageBuilder: (context, state) => CupertinoDialogPage<String>(
              key: state.pageKey,
              builder: (context) => const SampleCupertinoDialog(),
            ),
          ),
        ],
      ),
    ],
  );
}

class GoRouterHomePage extends StatefulWidget {
  const GoRouterHomePage({super.key});

  @override
  State<GoRouterHomePage> createState() => _GoRouterHomePageState();
}

class _GoRouterHomePageState extends State<GoRouterHomePage> {
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
            title: 'go_router Navigation',
            icon: Icons.route,
            buttons: [
              PopupDemoButton(
                label: 'Show Dialog',
                icon: Icons.chat_bubble_outline,
                description: 'Navigate to /dialog',
                onPressed: () async {
                  final result = await context.push<String>('/dialog');
                  _handleResult(result);
                },
              ),
              PopupDemoButton(
                label: 'Show Bottom Sheet',
                icon: Icons.vertical_align_bottom,
                description: 'Navigate to /bottom-sheet',
                onPressed: () async {
                  final result = await context.push<String>('/bottom-sheet');
                  _handleResult(result);
                },
              ),
              PopupDemoButton(
                label: 'Show Cupertino Dialog',
                icon: Icons.apple,
                description: 'Navigate to /cupertino-dialog',
                onPressed: () async {
                  final result =
                      await context.push<String>('/cupertino-dialog');
                  _handleResult(result);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          PopupDemoSection(
            title: 'Path-based Navigation',
            icon: Icons.link,
            buttons: [
              PopupDemoButton(
                label: 'Push via Path',
                icon: Icons.text_fields,
                description: 'Using pushPath method',
                onPressed: () async {
                  final result = await context.push<String>('/dialog');
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
                        'go_router Implementation',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'go_router v15 - '
                    'Official Flutter routing package. Each popup is defined as a route with its own path. '
                    'Supports deep linking, browser history, and declarative navigation.',
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
