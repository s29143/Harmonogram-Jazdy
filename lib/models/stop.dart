class Stop {
  final String id;
  final String name;

  const Stop({required this.id, required this.name});
}

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
