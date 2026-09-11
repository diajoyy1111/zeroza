import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'app_theme.dart';
import 'rong_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const RongApp());
}

class RongApp extends StatefulWidget {
  const RongApp({super.key});

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
      theme: RongTheme.light(),
      darkTheme: RongTheme.dark(),
      themeMode: _themeMode,
      home: RongOverlayWrapper(
        child: HomeScreen(onToggleTheme: toggleTheme, isDark: _themeMode == ThemeMode.dark),
      ),
    );
  }
}
