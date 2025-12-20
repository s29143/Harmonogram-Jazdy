import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZNotifier extends StateNotifier<String?> {
  static const _key = 'selected_zetka';
  final SharedPreferences prefs;

  ZNotifier(this.prefs) : super(prefs.getString(_key));

  void select(String zetka) {
    state = zetka;
    prefs.setString(_key, zetka);
  }
}
