import 'package:flutter_riverpod/legacy.dart';
import 'package:harmonogram/models/stop.dart';

class ServiceState {
  final List<Stop> stops;

  final Map<String, Map<int, List<int>>> minutesByStop;

  const ServiceState({required this.stops, required this.minutesByStop});

  factory ServiceState.initial() =>
      const ServiceState(stops: [], minutesByStop: {});

  ServiceState copyWith({
    List<Stop>? stops,
    Map<String, Map<int, List<int>>>? minutesByStop,
  }) {
    return ServiceState(
      stops: stops ?? this.stops,
      minutesByStop: minutesByStop ?? this.minutesByStop,
    );
  }
}

final serviceProvider =
    StateNotifierProvider.family<ServiceNotifier, ServiceState, String>(
      (ref, lineId) => ServiceNotifier(),
    );

class ServiceNotifier extends StateNotifier<ServiceState> {
  ServiceNotifier() : super(ServiceState.initial());

  Map<int, List<int>> _emptyHours() {
    final map = <int, List<int>>{};
    for (var h = 4; h <= 23; h++) {
      map[h] = <int>[];
    }
    return map;
  }

  void addStop(String name) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final stop = Stop(id: id, name: name);

    final nextMap = Map<String, Map<int, List<int>>>.from(state.minutesByStop);
    nextMap[stop.id] = _emptyHours();

    state = state.copyWith(
      stops: [...state.stops, stop],
      minutesByStop: nextMap,
    );
  }

  void removeStop(String stopId) {
    final nextStops = state.stops.where((s) => s.id != stopId).toList();
    final nextMap = Map<String, Map<int, List<int>>>.from(state.minutesByStop);
    nextMap.remove(stopId);

    state = state.copyWith(stops: nextStops, minutesByStop: nextMap);
  }

  List<int> minutesFor(String stopId, int hour) {
    return state.minutesByStop[stopId]?[hour] ?? const <int>[];
  }

  void setMinutes(String stopId, int hour, List<int> minutes) {
    if (hour < 4 || hour > 23) return;

    final cleaned = minutes.where((m) => m >= 0 && m <= 59).toSet().toList()
      ..sort();

    final nextMap = Map<String, Map<int, List<int>>>.from(state.minutesByStop);
    final stopHours = Map<int, List<int>>.from(
      nextMap[stopId] ?? _emptyHours(),
    );

    stopHours[hour] = cleaned;
    nextMap[stopId] = stopHours;

    state = state.copyWith(minutesByStop: nextMap);
  }
}
