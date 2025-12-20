import 'package:flutter/material.dart';

class ZButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ZButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 64,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          textStyle: const TextStyle(fontSize: 24),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
