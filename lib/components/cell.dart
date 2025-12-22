import 'package:flutter/material.dart';

class Cell extends StatelessWidget {
  final double width;
  final int? minutes;
  final bool dimmed;
  final bool highlight;
  final VoidCallback onEdit;

  const Cell({
    super.key,
    required this.width,
    required this.minutes,
    required this.dimmed,
    required this.highlight,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final text = minutes == null ? '—' : minutes!.toString().padLeft(2, '0');

    final borderColor = highlight ? Colors.red : Colors.transparent;
    final bg = dimmed ? Colors.grey.withAlpha((0.15 * 255).round()) : null;

    final textColor = highlight ? Colors.red : (dimmed ? Colors.grey : null);

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Card(
            margin: EdgeInsets.zero,
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 2),
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: highlight ? FontWeight.w700 : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
