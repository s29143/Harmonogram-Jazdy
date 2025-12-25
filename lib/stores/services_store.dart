import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harmonogram/models/day_type.dart';
import 'package:harmonogram/models/stop.dart';

class ServicesStore {
  static const _stopsPrefix = 'service_stops_';
  static const _minutesPrefix = 'service_minutes_';

  final SharedPreferences prefs;
  ServicesStore(this.prefs);

  String _stopsKey(String lineId) => '$_stopsPrefix$lineId';
  String _minutesKey(String lineId, DayType dayType) =>
      '$_minutesPrefix${lineId}_${dayType.key}';

  List<Stop> loadStops(String lineId) {
    final raw = prefs.getString(_stopsKey(lineId));
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Stop.fromJson)
        .toList();
  }

  Future<void> saveStops(String lineId, List<Stop> stops) async {
    final raw = jsonEncode(stops.map((s) => s.toJson()).toList());
    await prefs.setString(_stopsKey(lineId), raw);
  }

  Map<String, Map<int, int?>> loadMinutes(String lineId, DayType dayType) {
    final raw = prefs.getString(_minutesKey(lineId, dayType));
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};

    final out = <String, Map<int, int?>>{};
    decoded.forEach((stopId, hoursRaw) {
      final hoursMap = <int, int?>{};
      if (hoursRaw is Map<String, dynamic>) {
        hoursRaw.forEach((hourStr, minuteValue) {
          final hour = int.tryParse(hourStr);
          if (hour != null) hoursMap[hour] = minuteValue as int?;
        });
      }
      out[stopId] = hoursMap;
    });

    return out;
  }

  Future<void> saveMinutes(
    String lineId,
    DayType dayType,
    Map<String, Map<int, int?>> minutesByStop,
  ) async {
    final json = minutesByStop.map(
      (stopId, hours) =>
          MapEntry(stopId, hours.map((h, m) => MapEntry(h.toString(), m))),
    );
    await prefs.setString(_minutesKey(lineId, dayType), jsonEncode(json));
  }
}
