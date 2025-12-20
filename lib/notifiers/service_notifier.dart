import 'package:flutter_riverpod/legacy.dart';
import 'package:harmonogram/models/stop.dart';

class ServiceState {
  final List<Stop> stops;
  final Map<int, List<int>> minutesByHour;

  const ServiceState({required this.stops, required this.minutesByHour});

  ServiceState copyWith({
    List<Stop>? stops,
    Map<int, List<int>>? minutesByHour,
  }) {
    return ServiceState(
      stops: stops ?? this.stops,
      minutesByHour: minutesByHour ?? this.minutesByHour,
    );
  }

  factory ServiceState.initial() {
    final map = <int, List<int>>{};
    for (var h = 4; h <= 23; h++) {
      map[h] = <int>[];
    }
    return ServiceState(stops: const [], minutesByHour: map);
  }
}

final serviceProvider =
    StateNotifierProvider.family<ServiceNotifier, ServiceState, String>(
      (ref, lineId) => ServiceNotifier()..ensureSeed(),
    );

class ServiceNotifier extends StateNotifier<ServiceState> {
  ServiceNotifier() : super(ServiceState.initial());

  void ensureSeed() {
    if (state.stops.isNotEmpty) return;

    // Opcjonalne dane startowe, żeby od razu coś było widać
    state = state.copyWith(
      stops: const [
        Stop(id: 's1', name: 'Pętla'),
        Stop(id: 's2', name: 'Centrum'),
        Stop(id: 's3', name: 'Dworzec'),
      ],
    );

    // przykładowe minuty w wybranych godzinach
    addMinute(6, 5);
    addMinute(6, 25);
    addMinute(6, 45);
    addMinute(14, 10);
    addMinute(14, 40);
  }

  void addStop(String name) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = state.copyWith(
      stops: [
        ...state.stops,
        Stop(id: id, name: name),
      ],
    );
  }

  void removeStop(String stopId) {
    state = state.copyWith(
      stops: state.stops.where((s) => s.id != stopId).toList(),
    );
  }

  /// Dodaje minutę do danej godziny, trzyma posortowane i bez duplikatów.
  void addMinute(int hour, int minute) {
    if (hour < 4 || hour > 23) return;
    if (minute < 0 || minute > 59) return;

    final current = [...(state.minutesByHour[hour] ?? const <int>[])];
    if (current.contains(minute)) return;
    current.add(minute);
    current.sort();

    final copy = Map<int, List<int>>.from(state.minutesByHour);
    copy[hour] = current;
    state = state.copyWith(minutesByHour: copy);
  }

  void removeMinute(int hour, int minute) {
    final current = [...(state.minutesByHour[hour] ?? const <int>[])];
    current.remove(minute);

    final copy = Map<int, List<int>>.from(state.minutesByHour);
    copy[hour] = current;
    state = state.copyWith(minutesByHour: copy);
  }
}
