import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesStore {
  static const _prefix = 'service_state_';

  final SharedPreferences prefs;
  ServicesStore(this.prefs);

  String _key(String lineId) => '$_prefix$lineId';

  Map<String, dynamic>? loadRaw(String lineId) {
    final raw = prefs.getString(_key(lineId));
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Future<void> saveRaw(String lineId, Map<String, dynamic> json) async {
    final raw = jsonEncode(json);
    await prefs.setString(_key(lineId), raw);
  }

  Future<void> clear(String lineId) async {
    await prefs.remove(_key(lineId));
  }
}
