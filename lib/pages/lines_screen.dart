import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:harmonogram/main.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonogram/models/lines_store.dart';
import 'package:harmonogram/models/bus_line.dart';
import 'package:harmonogram/notifiers/lines_notifier.dart';

final linesStoreProvider = Provider<LinesStore>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return LinesStore(prefs);
});

final linesProvider = StateNotifierProvider<LinesNotifier, List<BusLine>>((
  ref,
) {
  final store = ref.read(linesStoreProvider);
  return LinesNotifier(store)..init();
});

class LinesScreen extends ConsumerWidget {
  const LinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = ref.watch(selectedZProvider);
    final allLines = ref.watch(linesProvider);

    final linesForZ = allLines.where((l) => l.z == z).toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    return Scaffold(
      appBar: AppBar(
        title: Text('Linie – $z'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLineDialog(context, ref, z ?? 'Z1'),
        child: const Icon(Icons.add),
      ),
      body: linesForZ.isEmpty
          ? const Center(
              child: Text(
                'Brak linii dla tej zetki.\nDodaj +',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              itemCount: linesForZ.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final line = linesForZ[index];
                return ListTile(
                  title: Text('Linia ${line.number}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(linesProvider.notifier).removeById(line.id);
                    },
                  ),
                  onTap: () {
                    ref.read(linesProvider.notifier).selectLine(line.id);
                    context.go('/services');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wybrano linię ${line.number}')),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _showAddLineDialog(
    BuildContext context,
    WidgetRef ref,
    String z,
  ) async {
    final numberCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Dodaj linię do $z'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberCtrl,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Numer linii (np. 101)',
                ),
              ),
            ],
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
        );
      },
    );

    if (result != true) return;

    final number = numberCtrl.text.trim();

    if (number.isEmpty && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Niepoprawne dane')));
      return;
    }

    await ref.read(linesProvider.notifier).addLine(z: z, number: number);
  }
}
