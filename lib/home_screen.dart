import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'clock_screen.dart';
import 'flashlight_screen.dart';
import 'todo_screen.dart';
import 'stopwatch_screen.dart';
import 'websearch_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const HomeScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final Set<String> _openedApps = {};
  bool _showEasterEgg = false;
  bool _easterEggSecondPart = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _openApp(String name, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleTween = Tween(begin: 0.92, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic));
          final fadeTween = Tween(begin: 0.0, end: 1.0);
          return ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      ),
    ).then((_) {
      setState(() {
        _openedApps.add(name);
        if (_openedApps.length >= 6 && !_showEasterEgg) {
          _showEasterEgg = true;
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _easterEggSecondPart = true);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0E0E12) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1F);
    final subtextColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RONG',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Everything is working correctly.',
                          style: TextStyle(
                            fontSize: 13,
                            color: subtextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: widget.onToggleTheme,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFF0EFF4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 22,
                          color: isDark ? Colors.amber[300] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.0,
                    children: [
                      _AppCard(
                        icon: Icons.calculate_rounded,
                        label: 'Calculator',
                        color: const Color(0xFF6750A4),
                        cardColor: cardColor,
                        onTap: () => _openApp('calculator', const CalculatorScreen()),
                      ),
                      _AppCard(
                        icon: Icons.access_time_filled_rounded,
                        label: 'Clock',
                        color: const Color(0xFF006D3F),
                        cardColor: cardColor,
                        onTap: () => _openApp('clock', const ClockScreen()),
                      ),
                      _AppCard(
                        icon: Icons.flashlight_on_rounded,
                        label: 'Flashlight',
                        color: const Color(0xFFE8A317),
                        cardColor: cardColor,
                        onTap: () => _openApp('flashlight', const FlashlightScreen()),
                      ),
                      _AppCard(
                        icon: Icons.check_circle_rounded,
                        label: 'To-Do',
                        color: const Color(0xFF006590),
                        cardColor: cardColor,
                        onTap: () => _openApp('todo', const TodoScreen()),
                      ),
                      _AppCard(
                        icon: Icons.timer_rounded,
                        label: 'Stopwatch',
                        color: const Color(0xFF9C2D2D),
                        cardColor: cardColor,
                        onTap: () => _openApp('stopwatch', const StopwatchScreen()),
                      ),
                      _AppCard(
                        icon: Icons.language_rounded,
                        label: 'Web Search',
                        color: const Color(0xFF00838F),
                        cardColor: cardColor,
                        onTap: () => _openApp('websearch', const WebSearchScreen()),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showEasterEgg)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      _easterEggSecondPart
                          ? '...probably.'
                          : '✓ All systems functioning normally.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _easterEggSecondPart
                            ? (isDark ? Colors.grey[600] : Colors.grey[400])
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              if (!_showEasterEgg) const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color cardColor;
  final VoidCallback onTap;

  const _AppCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1C1B1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
