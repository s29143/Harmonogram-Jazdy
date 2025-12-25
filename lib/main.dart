import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harmonogram/pages/day_type_screen.dart';
import 'package:harmonogram/pages/z_screen.dart';
import 'package:harmonogram/pages/lines_screen.dart';
import 'package:harmonogram/pages/services_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DayTypeScreen()),
    GoRoute(path: '/z', builder: (context, state) => const ZScreen()),
    GoRoute(path: '/lines', builder: (context, state) => const LinesScreen()),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kursy autobusu',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    );
  }
}
