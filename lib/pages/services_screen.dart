import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmonogram/components/stops_panel.dart';
import 'package:harmonogram/components/stops_schedule_grid.dart';

import 'package:harmonogram/models/bus_line.dart';
import 'package:harmonogram/notifiers/service_notifier.dart';
import 'package:harmonogram/pages/lines_screen.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linesNotifier = ref.read(linesProvider.notifier);
    final BusLine? line = linesNotifier.selectedLine;

    if (line == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kurs')),
        body: const Center(
          child: Text('Nie wybrano linii.\nWróć i wybierz linię.'),
        ),
      );
    }

    final state = ref.watch(serviceProvider(line.id));

    return Scaffold(
      appBar: AppBar(title: Text('Kurs — linia ${line.number} (${line.z})')),
      body: Row(
        children: [
          SizedBox(
            width: 320,
            child: StopsPanel(
              stops: state.stops,
              onAdd: () => _showAddStopDialog(context, ref, line.id),
              onRemove: (stopId) => ref
                  .read(serviceProvider(line.id).notifier)
                  .removeStop(stopId),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: StopsScheduleGrid(
              stops: state.stops,
              minutesByStop: state.minutesByStop,
              onEditCell: (stopId, hour) {
                final current =
                    state.minutesByStop[stopId]?[hour] ?? const <int>[];
                _editCellDialog(context, ref, line.id, stopId, hour, current);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editCellDialog(
    BuildContext context,
    WidgetRef ref,
    String lineId,
    String stopId,
    int hour,
    List<int> current,
  ) async {
    final ctrl = TextEditingController(
      text: current.map((m) => m.toString().padLeft(2, '0')).join(' '),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edycja — ${hour.toString().padLeft(2, '0')}:__'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Minuty',
            hintText: 'np. 03 05 08 lub 3,5,8',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final minutes = _parseMinutes(ctrl.text);

    if (minutes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Niepoprawny format (0–59)')),
      );
      return;
    }

    ref
        .read(serviceProvider(lineId).notifier)
        .setMinutes(stopId, hour, minutes);
  }

  List<int>? _parseMinutes(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return <int>[];

    // separator: spacja, przecinek, średnik, dwukropek, tab
    final parts = trimmed.split(RegExp(r'[\s,;:]+')).where((p) => p.isNotEmpty);

    final out = <int>[];
    for (final p in parts) {
      final v = int.tryParse(p);
      if (v == null || v < 0 || v > 59) return null;
      out.add(v);
    }

    // unikat + sort
    final unique = out.toSet().toList()..sort();
    return unique;
  }

  Future<void> _showAddStopDialog(
    BuildContext context,
    WidgetRef ref,
    String lineId,
  ) async {
    final ctrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dodaj przystanek'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nazwa przystanku',
            hintText: 'np. Dworzec',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final name = ctrl.text.trim();
    if (name.isEmpty) return;

    ref.read(serviceProvider(lineId).notifier).addStop(name);
  }
}
