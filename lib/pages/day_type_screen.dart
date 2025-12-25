import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonogram/components/z_button.dart';
import 'package:harmonogram/models/day_type.dart';
import 'package:harmonogram/notifiers/day_type_notifier.dart';

class DayTypeScreen extends ConsumerWidget {
  const DayTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDayTypeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wybierz dzień')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZButton(
              label: 'Dni powszednie',
              selected: selected == DayType.weekday,
              onTap: () {
                ref
                    .read(selectedDayTypeProvider.notifier)
                    .setDayType(DayType.weekday);
                context.go('/z');
              },
            ),
            const SizedBox(height: 24),
            ZButton(
              label: 'Sobota',
              selected: selected == DayType.saturday,
              onTap: () {
                ref
                    .read(selectedDayTypeProvider.notifier)
                    .setDayType(DayType.saturday);
                context.go('/z');
              },
            ),
            const SizedBox(height: 24),
            ZButton(
              label: 'Niedziela i święta',
              selected: selected == DayType.sundayHoliday,
              onTap: () {
                ref
                    .read(selectedDayTypeProvider.notifier)
                    .setDayType(DayType.sundayHoliday);
                context.go('/z');
              },
            ),
          ],
        ),
      ),
    );
  }
}
