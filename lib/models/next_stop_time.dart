import 'package:flutter/cupertino.dart';

class NextStopTime {
  final String stopId;
  final int hour;
  final int minute;

  const NextStopTime({
    required this.stopId,
    required this.hour,
    required this.minute,
  });

  static NextStopTime? findNext(
    DateTime now,
    Map<String, Map<int, int?>> minutesByStop,
  ) {
    NextStopTime? best;
    Duration? bestDiff;

    final today = DateTime(now.year, now.month, now.day);

    for (final entry in minutesByStop.entries) {
      final stopId = entry.key;
      final hoursMap = entry.value;

      for (final hm in hoursMap.entries) {
        final hour = hm.key;
        final minute = hm.value;
        if (minute == null) continue;

        if (hour < 4 || hour > 23) continue;
        if (minute < 0 || minute > 59) continue;

        final candidate = DateTime(
          today.year,
          today.month,
          today.day,
          hour,
          minute,
        );

        if (!candidate.isAfter(now)) continue;

        final diff = candidate.difference(now);
        if (bestDiff == null || diff < bestDiff) {
          bestDiff = diff;
          best = NextStopTime(stopId: stopId, hour: hour, minute: minute);
        }
      }
    }
    debugPrint('NextStopTime.findNext: best=$best');
    return best;
  }

  @override
  String toString() {
    return 'NextStopTime(stopId: $stopId, hour: $hour, minute: $minute)';
  }
}
