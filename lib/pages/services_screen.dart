import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:harmonogram/models/bus_line.dart';
import 'package:harmonogram/models/stop.dart';
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

    // UWAGA: tutaj bierzemy stan DLA KONKRETNEJ LINII
    final state = ref.watch(serviceProvider(line.id));

    return Scaffold(
      appBar: AppBar(title: Text('Kurs — linia ${line.number} (${line.z})')),
      body: Row(
        children: [
          SizedBox(
            width: 320,
            child: _StopsPanel(
              stops: state.stops,
              onAdd: () => _showAddStopDialog(context, ref, line.id),
              onRemove: (stopId) => ref
                  .read(serviceProvider(line.id).notifier)
                  .removeStop(stopId),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _HoursTable(
              minutesByHour: state.minutesByHour,
              onAddMinute: (hour) =>
                  _showAddMinuteDialog(context, ref, line.id, hour),
              onRemoveMinute: (hour, minute) => ref
                  .read(serviceProvider(line.id).notifier)
                  .removeMinute(hour, minute),
            ),
          ),
        ],
      ),
    );
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

    // POPRAWKA: używamy serviceProvider(lineId)
    ref.read(serviceProvider(lineId).notifier).addStop(name);
  }

  Future<void> _showAddMinuteDialog(
    BuildContext context,
    WidgetRef ref,
    String lineId,
    int hour,
  ) async {
    final ctrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Dodaj minutę — $hour:__'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minuta (0–59)',
            hintText: 'np. 05',
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

    final minute = int.tryParse(ctrl.text.trim());
    if (minute == null || minute < 0 || minute > 59) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Podaj minutę 0–59')));
      return;
    }

    ref.read(serviceProvider(lineId).notifier).addMinute(hour, minute);
  }
}

class _StopsPanel extends StatelessWidget {
  final List<Stop> stops;
  final VoidCallback onAdd;
  final void Function(String stopId) onRemove;

  const _StopsPanel({
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
                  separatorBuilder: (_, __) => const Divider(height: 1),
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

class _HoursTable extends StatelessWidget {
  final Map<int, List<int>> minutesByHour;
  final void Function(int hour) onAddMinute;
  final void Function(int hour, int minute) onRemoveMinute;

  const _HoursTable({
    required this.minutesByHour,
    required this.onAddMinute,
    required this.onRemoveMinute,
  });

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(20, (i) => i + 4); // 4..23

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: const [
              Text(
                'Godziny jazdy (4–23)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final h in hours)
                  _HourColumn(
                    hour: h,
                    minutes: minutesByHour[h] ?? const <int>[],
                    onAdd: () => onAddMinute(h),
                    onRemove: (m) => onRemoveMinute(h, m),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HourColumn extends StatelessWidget {
  final int hour;
  final List<int> minutes;
  final VoidCallback onAdd;
  final void Function(int minute) onRemove;

  const _HourColumn({
    required this.hour,
    required this.minutes,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hour.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    tooltip: 'Dodaj minutę',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (minutes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('—', style: TextStyle(fontSize: 16)),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final m in minutes)
                      InputChip(
                        label: Text(m.toString().padLeft(2, '0')),
                        onDeleted: () => onRemove(m),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
