import 'dart:convert';

import 'package:harmonogram/models/bus_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinesStore {
  static const _key = 'lines';
  final SharedPreferences prefs;

  LinesStore(this.prefs);

  List<BusLine> load() {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BusLine.fromJson)
        .toList();
  }

  Future<void> save(List<BusLine> lines) async {
    final raw = jsonEncode(lines.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
