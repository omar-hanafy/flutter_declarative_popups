import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupDemoSection extends StatelessWidget {
  const PopupDemoSection({
    super.key,
    required this.title,
    required this.buttons,
    this.icon,
  });

  final String title;
  final List<PopupDemoButton> buttons;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 24),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...buttons,
          ],
        ),
      ),
    );
  }
}

class PopupDemoButton extends StatelessWidget {
  const PopupDemoButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.description,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              if (description != null)
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}

// Sample dialogs that will be used across all examples
class SampleDialog extends StatelessWidget {
  const SampleDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sample Dialog'),
      content: const Text(
        'This dialog was shown using flutter_declarative_popups.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop('Cancelled'),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop('Confirmed'),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class SampleBottomSheet extends StatelessWidget {
  const SampleBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sample Bottom Sheet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This bottom sheet was created with flutter_declarative_popups',
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('Option 1'),
                child: const Text('Option 1'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('Option 2'),
                child: const Text('Option 2'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('Option 3'),
                child: const Text('Option 3'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class SampleCupertinoDialog extends StatelessWidget {
  const SampleCupertinoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Cupertino Dialog'),
      content: const Text(
        'This is an iOS-style dialog created with flutter_declarative_popups',
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop('Cancelled'),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop('OK Pressed'),
          isDefaultAction: true,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
