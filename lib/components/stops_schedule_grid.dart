import 'package:flutter/material.dart';
import 'package:harmonogram/components/cell.dart';
import 'package:harmonogram/models/stop.dart';

class StopsScheduleGrid extends StatelessWidget {
  final List<Stop> stops;
  final Map<String, Map<int, int?>> minutesByStop;
  final void Function(String stopId, int hour) onEditCell;

  const StopsScheduleGrid({
    super.key,
    required this.stops,
    required this.minutesByStop,
    required this.onEditCell,
  });

  static const double stopNameWidth = 160;
  static const double cellWidth = 120;
  static const double headerHeight = 52;
  static const double rowHeight = 72;

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(20, (i) => i + 4);
    final totalWidth = stopNameWidth + (hours.length * cellWidth);

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: Row(
                  children: [
                    const SizedBox(width: stopNameWidth),
                    for (final h in hours)
                      SizedBox(
                        width: cellWidth,
                        child: Center(
                          child: Text(
                            h.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: stops.isEmpty
                    ? const Center(child: Text('Brak przystanków'))
                    : ListView.separated(
                        itemCount: stops.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final stop = stops[i];

                          return SizedBox(
                            height: rowHeight,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: stopNameWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        stop.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                for (final h in hours)
                                  Cell(
                                    width: cellWidth,
                                    minutes: minutesByStop[stop.id]?[h],
                                    onEdit: () => onEditCell(stop.id, h),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
