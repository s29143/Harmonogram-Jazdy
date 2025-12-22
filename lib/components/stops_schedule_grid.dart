import 'package:flutter/material.dart';
import 'package:harmonogram/components/cell.dart';
import 'package:harmonogram/models/stop.dart';

class StopsScheduleGrid extends StatefulWidget {
  final List<Stop> stops;
  final Map<String, Map<int, int?>> minutesByStop;
  final void Function(String stopId, int hour) onEditCell;

  final DateTime now;
  final String? highlightedStopId;
  final int? highlightedHour;
  final int? highlightedMinute;

  const StopsScheduleGrid({
    super.key,
    required this.now,
    required this.stops,
    required this.minutesByStop,
    required this.onEditCell,
    this.highlightedStopId,
    this.highlightedHour,
    this.highlightedMinute,
  });

  static const double stopNameWidth = 160;
  static const double cellWidth = 120;
  static const double headerHeight = 52;
  static const double rowHeight = 72;

  @override
  State<StopsScheduleGrid> createState() => _StopsScheduleGridState();
}

class _StopsScheduleGridState extends State<StopsScheduleGrid> {
  late final ScrollController _hCtrl;
  late final ScrollController _vGridCtrl;
  late final ScrollController _vStickyCtrl;

  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _hCtrl = ScrollController();
    _vGridCtrl = ScrollController();
    _vStickyCtrl = ScrollController();

    _vGridCtrl.addListener(() {
      if (_syncing) return;
      if (!_vStickyCtrl.hasClients) return;

      _syncing = true;
      final max = _vStickyCtrl.position.maxScrollExtent;
      final target = _vGridCtrl.offset.clamp(0.0, max);
      _vStickyCtrl.jumpTo(target);
      _syncing = false;
    });
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _vGridCtrl.dispose();
    _vStickyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(20, (i) => i + 4);
    final gridWidth = hours.length * StopsScheduleGrid.cellWidth;
    final totalWidth = StopsScheduleGrid.stopNameWidth + gridWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Scrollbar(
              controller: _hCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _hCtrl,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      SizedBox(
                        height: StopsScheduleGrid.headerHeight,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: StopsScheduleGrid.stopNameWidth,
                            ),
                            for (final h in hours)
                              SizedBox(
                                width: StopsScheduleGrid.cellWidth,
                                child: Center(
                                  child: Text(
                                    h.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: (h < widget.now.hour)
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: widget.stops.isEmpty
                            ? const Center(child: Text('Brak przystanków'))
                            : Scrollbar(
                                controller: _vGridCtrl,
                                thumbVisibility: true,
                                child: ListView.separated(
                                  controller: _vGridCtrl,
                                  itemCount: widget.stops.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final stop = widget.stops[i];
                                    return SizedBox(
                                      height: StopsScheduleGrid.rowHeight,
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width:
                                                StopsScheduleGrid.stopNameWidth,
                                          ),
                                          for (final h in hours)
                                            _buildCell(stop.id, h),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: StopsScheduleGrid.stopNameWidth,
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: StopsScheduleGrid.headerHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Przystanek',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: widget.stops.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.separated(
                              controller: _vStickyCtrl,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.stops.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final stop = widget.stops[i];
                                return SizedBox(
                                  height: StopsScheduleGrid.rowHeight,
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
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: StopsScheduleGrid.stopNameWidth,
              top: 0,
              bottom: 0,
              child: const VerticalDivider(width: 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCell(String stopId, int hour) {
    final minute = widget.minutesByStop[stopId]?[hour];

    final highlight =
        widget.highlightedStopId == stopId &&
        widget.highlightedHour == hour &&
        widget.highlightedMinute == minute;

    final dimmed =
        (hour < widget.now.hour) ||
        (hour == widget.now.hour &&
            minute != null &&
            minute < widget.now.minute);

    return Cell(
      width: StopsScheduleGrid.cellWidth,
      minutes: minute,
      dimmed: dimmed,
      highlight: highlight,
      onEdit: () => widget.onEditCell(stopId, hour),
    );
  }
}
