import 'package:flutter_riverpod/legacy.dart';
import 'package:harmonogram/models/bus_line.dart';
import 'package:harmonogram/models/lines_store.dart';

class LinesNotifier extends StateNotifier<List<BusLine>> {
  final LinesStore store;

  LinesNotifier(this.store) : super(const []);

  void init() {
    state = store.loadLines();
  }

  List<BusLine> byZ(String z) =>
      state.where((l) => l.z == z).toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  BusLine? byId(String id) {
    try {
      return state.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addLine({required String z, required String number}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final line = BusLine(id: id, z: z, number: number);

    state = [...state, line];
    await store.saveLines(state);
  }

  Future<void> removeById(String id) async {
    state = state.where((l) => l.id != id).toList();
    await store.saveLines(state);

    final selectedId = store.loadSelectedLineId();
    if (selectedId == id) {
      await store.clearSelectedLine();
    }
  }

  String? get selectedLineId => store.loadSelectedLineId();

  BusLine? get selectedLine {
    final id = selectedLineId;
    if (id == null) return null;
    return byId(id);
  }

  Future<void> selectLine(String lineId) async {
    await store.saveSelectedLineId(lineId);
  }

  Future<void> clearSelectedLine() async {
    await store.clearSelectedLine();
  }
}
