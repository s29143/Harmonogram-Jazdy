import 'dart:convert';

import 'package:harmonogram/models/bus_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinesStore {
  static const _linesKey = 'lines';
  static const _selectedLineKey = 'selected_line_id';
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  final SharedPreferences prefs;

  LinesStore(this.prefs);

  List<BusLine> loadLines() {
    final raw = prefs.getString(_linesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BusLine.fromJson)
        .toList();
  }

  Future<void> saveLines(List<BusLine> lines) async {
    final raw = jsonEncode(lines.map((e) => e.toJson()).toList());
    await prefs.setString(_linesKey, raw);
  }

  String? loadSelectedLineId() {
    return prefs.getString(_selectedLineKey);
  }

  Future<void> saveSelectedLineId(String lineId) async {
    await prefs.setString(_selectedLineKey, lineId);
  }

  Future<void> clearSelectedLine() async {
    await prefs.remove(_selectedLineKey);
  }

  void setEditing(bool editing) {
    _isEditing = editing;
  }
}
