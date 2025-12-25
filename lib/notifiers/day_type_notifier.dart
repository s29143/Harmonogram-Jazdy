import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmonogram/main.dart';
import 'package:harmonogram/models/day_type.dart';

final selectedDayTypeProvider = NotifierProvider<DayTypeNotifier, DayType>(
  DayTypeNotifier.new,
);

class DayTypeNotifier extends Notifier<DayType> {
  static const _key = 'day_type';

  @override
  DayType build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return DayTypeX.fromKey(prefs.getString(_key));
  }

  DayType get dayType => state;

  Future<void> setDayType(DayType type) async {
    state = type;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, type.key);
  }
}
