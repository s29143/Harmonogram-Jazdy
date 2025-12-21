import 'package:flutter/material.dart';
import 'package:harmonogram/models/stop.dart';

class StopsPanel extends StatelessWidget {
  final List<Stop> stops;
  final VoidCallback onAdd;
  final void Function(String stopId) onRemove;

  const StopsPanel({
    super.key,
    required this.stops,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Przystanki',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Dodaj przystanek',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: stops.isEmpty
              ? const Center(
                  child: Text(
                    'Brak przystanków.\nDodaj +',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  itemCount: stops.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = stops[i];
                    return ListTile(
                      dense: true,
                      title: Text(s.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onRemove(s.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
