import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmonogram/main.dart';

class ZNotifier extends Notifier<String?> {
  static const _key = 'selected_z';

  @override
  String? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(_key);
  }

  Future<void> setZ(String z) async {
    state = z;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, z);
  }

  Future<void> clear() async {
    state = null;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_key);
  }
}
