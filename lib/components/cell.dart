import 'package:flutter/material.dart';

class Cell extends StatelessWidget {
  final double width;
  final int? minutes;
  final VoidCallback onEdit;

  const Cell({
    super.key,
    required this.width,
    required this.minutes,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final text = minutes == null ? '-' : minutes.toString().padLeft(2, '0');

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Card(
            margin: EdgeInsets.zero,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
