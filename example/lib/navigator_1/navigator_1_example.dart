import 'package:flutter/material.dart';
import 'package:flutter_declarative_popups/flutter_declarative_popups.dart';
import '../shared/popup_demo_widget.dart';
import '../shared/result_display.dart';

class Navigator1Example extends StatelessWidget {
  const Navigator1Example({super.key});

  @override
  Widget build(BuildContext context) {
    return const Navigator1HomePage();
  }
}

class Navigator1HomePage extends StatefulWidget {
  const Navigator1HomePage({super.key});

  @override
  State<Navigator1HomePage> createState() => _Navigator1HomePageState();
}

class _Navigator1HomePageState extends State<Navigator1HomePage> {
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
            title: 'Direct Push Methods',
            icon: Icons.push_pin,
            buttons: [
              PopupDemoButton(
                label: 'Show Dialog (Direct)',
                icon: Icons.chat_bubble_outline,
                description: 'Using showDialog directly',
                onPressed: () async {
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => const SampleDialog(),
                  );
                  _handleResult(result);
                },
              ),
              PopupDemoButton(
                label: 'Show Bottom Sheet (Direct)',
                icon: Icons.vertical_align_bottom,
                description: 'Using showModalBottomSheet directly',
                onPressed: () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => const SampleBottomSheet(),
                  );
                  _handleResult(result);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          PopupDemoSection(
            title: 'Navigator 1.0 with Declarative Pages',
            icon: Icons.navigate_next,
            buttons: [
              PopupDemoButton(
                label: 'Push DialogPage',
                icon: Icons.chat_bubble,
                description: 'Using Navigator.push with DialogPage',
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    DialogPage<String>(
                      builder: (context) => const SampleDialog(),
                    ).createRoute(context),
                  );
                  _handleResult(result);
                },
              ),
              PopupDemoButton(
                label: 'Push ModalBottomSheetPage',
                icon: Icons.upload,
                description: 'Using Navigator.push with ModalBottomSheetPage',
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    ModalBottomSheetPage<String>(
                      builder: (context) => const SampleBottomSheet(),
                      showDragHandle: true,
                    ).createRoute(context),
                  );
                  _handleResult(result);
                },
              ),
              PopupDemoButton(
                label: 'Push CupertinoDialogPage',
                icon: Icons.apple,
                description: 'Using Navigator.push with CupertinoDialogPage',
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    CupertinoDialogPage<String>(
                      builder: (context) => const SampleCupertinoDialog(),
                    ).createRoute(context),
                  );
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
                        'Navigator 1.0 Implementation',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This example shows both traditional imperative navigation '
                    'and how to use flutter_declarative_popups pages with Navigator 1.0. '
                    'Note: Path-based navigation is not available with Navigator 1.0.',
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
