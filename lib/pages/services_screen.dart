import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:harmonogram/components/stops_panel.dart';
import 'package:harmonogram/components/stops_schedule_grid.dart';
import 'package:harmonogram/models/bus_line.dart';
import 'package:harmonogram/notifiers/service_notifier.dart';
import 'package:harmonogram/pages/lines_screen.dart';

final serviceProvider =
    NotifierProvider.family<ServiceNotifier, ServiceState, String>(
      ServiceNotifier.new,
    );

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text('Kurs — linia ${line.number} (${line.z})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/lines'),
        ),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: StopsPanel(
              stops: state.stops,
              onAdd: () => _showAddStopDialog(context, line.id),
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
                final current = state.minutesByStop[stopId]?[hour];
                _editCellDialog(context, line.id, stopId, hour, current);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editCellDialog(
    BuildContext context,
    String lineId,
    String stopId,
    int hour,
    int? current,
  ) async {
    final ctrl = TextEditingController(
      text: current != null ? current.toString() : '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edycja — ${hour.toString().padLeft(2, '0')}:__'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Minuty',
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
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final parsed = int.tryParse(ctrl.text.trim());

    final int? minute = (ctrl.text.trim().isEmpty) ? null : parsed;

    // Walidacja
    if (context.mounted && minute != null && (minute < 0 || minute > 59)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Podaj minutę 0–59')));
      return;
    }

    await ref
        .read(serviceProvider(lineId).notifier)
        .setMinutes(stopId, hour, minute);
  }

  Future<void> _showAddStopDialog(BuildContext context, String lineId) async {
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

    await ref.read(serviceProvider(lineId).notifier).addStop(name);
  }
}
