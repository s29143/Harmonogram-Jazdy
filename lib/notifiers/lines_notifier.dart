import 'package:flutter_riverpod/legacy.dart';
import 'package:harmonogram/models/Lines_store.dart';
import 'package:harmonogram/models/bus_line.dart';

class LinesNotifier extends StateNotifier<List<BusLine>> {
  final LinesStore store;

  LinesNotifier(this.store) : super(const []);

  void init() {
    state = store.load();

    if (state.isEmpty) {
      state = const [
        BusLine(id: 'l1', z: 'Z1', number: '101', stopsCount: 18),
        BusLine(id: 'l2', z: 'Z1', number: '102', stopsCount: 22),
        BusLine(id: 'l3', z: 'Z3', number: '201', stopsCount: 15),
      ];
      store.save(state);
    }
  }

  List<BusLine> byZ(String z) => state.where((l) => l.z == z).toList();

  Future<void> addLine({
    required String z,
    required String number,
    required int stopsCount,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final line = BusLine(id: id, z: z, number: number, stopsCount: stopsCount);

    state = [...state, line];
    await store.save(state);
  }

  Future<void> removeById(String id) async {
    state = state.where((l) => l.id != id).toList();
    await store.save(state);
  }
}
