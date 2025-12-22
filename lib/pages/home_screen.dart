import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonogram/components/z_button.dart';
import 'package:harmonogram/notifiers/z_notifier.dart';

final selectedZProvider = NotifierProvider<ZNotifier, String?>(ZNotifier.new);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedZProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wybierz zetkę')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZButton(
              label: 'Z1',
              selected: selected == 'Z1',
              onTap: () {
                ref.read(selectedZProvider.notifier).setZ('Z1');
                context.go('/lines');
              },
            ),
            const SizedBox(height: 24),
            ZButton(
              label: 'Z3',
              selected: selected == 'Z3',
              onTap: () {
                ref.read(selectedZProvider.notifier).setZ('Z3');
                context.go('/lines');
              },
            ),
          ],
        ),
      ),
    );
  }
}
