import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const RongApp());
}

class RongApp extends StatefulWidget {
  const RongApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<RongApp> createState() => RongAppState();
}

class RongAppState extends State<RongApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RONG',
      debugShowCheckedModeBanner: false,
      navigatorKey: RongApp.navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: HomeScreen(onToggleTheme: toggleTheme, isDark: _themeMode == ThemeMode.dark),
    );
  }
}
