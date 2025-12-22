import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmonogram/main.dart';
import 'package:harmonogram/models/stop.dart';
import 'package:harmonogram/pages/services_screen.dart';
import 'package:harmonogram/stores/services_store.dart';

class ServiceState {
  final List<Stop> stops;
  final Map<String, Map<int, int?>> minutesByStop;

  const ServiceState({required this.stops, required this.minutesByStop});

  factory ServiceState.initial() =>
      const ServiceState(stops: [], minutesByStop: {});

  ServiceState copyWith({
    List<Stop>? stops,
    Map<String, Map<int, int?>>? minutesByStop,
  }) {
    return ServiceState(
      stops: stops ?? this.stops,
      minutesByStop: minutesByStop ?? this.minutesByStop,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stops': stops.map((s) => s.toJson()).toList(),
      'minutesByStop': minutesByStop.map(
        (key, value) =>
            MapEntry(key, value.map((h, m) => MapEntry(h.toString(), m))),
      ),
    };
  }

  factory ServiceState.fromJson(Map<String, dynamic> json) {
    final stopsRaw = json['stops'] as List<dynamic>? ?? [];
    final minutesRaw = json['minutesByStop'] as Map<String, dynamic>? ?? {};

    final stops = stopsRaw
        .whereType<Map<String, dynamic>>()
        .map(Stop.fromJson)
        .toList();

    final minutesByStop = <String, Map<int, int?>>{};
    minutesRaw.forEach((stopId, hoursRaw) {
      final hoursMap = <int, int?>{};
      if (hoursRaw is Map<String, dynamic>) {
        hoursRaw.forEach((hourStr, minuteValue) {
          final hour = int.tryParse(hourStr);
          if (hour != null) {
            hoursMap[hour] = minuteValue as int?;
          }
        });
      }
      minutesByStop[stopId] = hoursMap;
    });

    return ServiceState(stops: stops, minutesByStop: minutesByStop);
  }
}

final servicesStoreProvider = Provider<ServicesStore>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ServicesStore(prefs);
});

class ServiceNotifier extends Notifier<ServiceState> {
  ServiceNotifier(this.lineId);
  final String lineId;

  @override
  ServiceState build() {
    final store = ref.read(servicesStoreProvider);
    final raw = store.loadRaw(lineId);
    if (raw != null) return ServiceState.fromJson(raw);

    return ServiceState.initial();
  }

  Map<int, int?> _emptyHours() {
    final map = <int, int?>{};
    for (var h = 4; h <= 23; h++) {
      map[h] = null;
    }
    return map;
  }

  Future<void> _persist() async {
    final store = ref.read(servicesStoreProvider);
    await store.saveRaw(lineId, state.toJson());
  }

  Future<void> addStop(String name) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final stop = Stop(id: id, name: name);

    final nextMap = Map<String, Map<int, int?>>.from(state.minutesByStop);
    nextMap[stop.id] = _emptyHours();

    state = state.copyWith(
      stops: [...state.stops, stop],
      minutesByStop: nextMap,
    );

    await _persist();
  }

  Future<void> removeStop(String stopId) async {
    final nextStops = state.stops.where((s) => s.id != stopId).toList();
    final nextMap = Map<String, Map<int, int?>>.from(state.minutesByStop)
      ..remove(stopId);

    state = state.copyWith(stops: nextStops, minutesByStop: nextMap);
    await _persist();
  }

  Future<void> setMinutes(String stopId, int hour, int? minutes) async {
    if (hour < 4 || hour > 23) return;
    if (minutes != null && (minutes < 0 || minutes > 59)) return;

    final nextMap = Map<String, Map<int, int?>>.from(state.minutesByStop);
    final stopHours = Map<int, int?>.from(nextMap[stopId] ?? _emptyHours());

    stopHours[hour] = minutes;
    nextMap[stopId] = stopHours;

    state = state.copyWith(minutesByStop: nextMap);
    await _persist();
  }
}
