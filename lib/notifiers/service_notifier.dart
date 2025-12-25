import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harmonogram/main.dart';
import 'package:harmonogram/models/service_key.dart';
import 'package:harmonogram/models/stop.dart';
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
  ServiceNotifier(this.serviceKey);
  final ServiceKey serviceKey;

  @override
  ServiceState build() {
    final store = ref.read(servicesStoreProvider);

    final stops = store.loadStops(serviceKey.lineId);

    var minutesByStop = store.loadMinutes(
      serviceKey.lineId,
      serviceKey.dayType,
    );

    minutesByStop = _normalizeMinutesForStops(stops, minutesByStop);

    return ServiceState(stops: stops, minutesByStop: minutesByStop);
  }

  Map<int, int?> _emptyHours() {
    final map = <int, int?>{};
    for (var h = 3; h <= 23; h++) {
      map[h] = null;
    }
    return map;
  }

  Map<String, Map<int, int?>> _normalizeMinutesForStops(
    List<Stop> stops,
    Map<String, Map<int, int?>> minutesByStop,
  ) {
    final next = Map<String, Map<int, int?>>.from(minutesByStop);

    for (final s in stops) {
      next[s.id] = Map<int, int?>.from(next[s.id] ?? _emptyHours());

      for (var h = 3; h <= 23; h++) {
        next[s.id]!.putIfAbsent(h, () => null);
      }
    }

    final stopIds = stops.map((e) => e.id).toSet();
    next.removeWhere((stopId, _) => !stopIds.contains(stopId));

    return next;
  }

  Future<void> _persistStops() async {
    final store = ref.read(servicesStoreProvider);
    await store.saveStops(serviceKey.lineId, state.stops);
  }

  Future<void> _persistMinutes() async {
    final store = ref.read(servicesStoreProvider);
    await store.saveMinutes(
      serviceKey.lineId,
      serviceKey.dayType,
      state.minutesByStop,
    );
  }

  Future<void> addStop(String name) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final stop = Stop(id: id, name: name);

    final nextStops = [...state.stops, stop];

    final nextMinutes = Map<String, Map<int, int?>>.from(state.minutesByStop);
    nextMinutes[stop.id] = _emptyHours();

    state = state.copyWith(stops: nextStops, minutesByStop: nextMinutes);

    await _persistStops();
    await _persistMinutes();
  }

  Future<void> removeStop(String stopId) async {
    final nextStops = state.stops.where((s) => s.id != stopId).toList();

    final nextMinutes = Map<String, Map<int, int?>>.from(state.minutesByStop)
      ..remove(stopId);

    state = state.copyWith(stops: nextStops, minutesByStop: nextMinutes);

    await _persistStops();
    await _persistMinutes();
  }

  Future<void> setMinutes(String stopId, int hour, int? minutes) async {
    if (hour < 3 || hour > 23) return;
    if (minutes != null && (minutes < 0 || minutes > 59)) return;

    final nextMap = Map<String, Map<int, int?>>.from(state.minutesByStop);
    final stopHours = Map<int, int?>.from(nextMap[stopId] ?? _emptyHours());

    stopHours[hour] = minutes;
    nextMap[stopId] = stopHours;

    state = state.copyWith(minutesByStop: nextMap);
    await _persistMinutes();
  }
}
