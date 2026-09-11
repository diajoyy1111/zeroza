import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calculator_screen.dart';
import 'clock_screen.dart';
import 'flashlight_screen.dart';
import 'todo_screen.dart';
import 'stopwatch_screen.dart';
import 'websearch_screen.dart';
import 'camera_screen.dart';
import 'messages_screen.dart';
import 'app_theme.dart';
import 'app_widgets.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const HomeScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Set<String> _openedApps = {};
  bool _showEasterEgg = false;
  bool _easterEggSecondPart = false;
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _staggerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _cardAnimations = List.generate(8, (index) {
      final start = (index * 0.08).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });
    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _openApp(String name, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );
          final slide = Tween(begin: const Offset(0.04, 0.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    ).then((_) {
      setState(() {
        _openedApps.add(name);
        if (_openedApps.length >= 8 && !_showEasterEgg) {
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
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.cardDark : AppColors.card;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            children: [
              RongHeader(
                title: 'RONG',
                subtitle: 'Everything is working correctly.',
                trailing: _ThemeToggle(
                  isDark: isDark,
                  onTap: widget.onToggleTheme,
                ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: List.generate(8, (index) {
                      return AnimatedBuilder(
                        animation: _cardAnimations[index],
                        builder: (context, child) {
                          return Opacity(
                            opacity: _cardAnimations[index].value,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - _cardAnimations[index].value)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildAppCard(index, cardColor, isDark),
                      );
                    }),
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
                      _easterEggSecondPart ? '...probably.' : '✓ All systems functioning normally.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _easterEggSecondPart
                            ? (isDark ? AppColors.textDarkSecondary : AppColors.textSecondary)
                            : AppColors.clockIcon,
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

  Widget _buildAppCard(int index, Color cardColor, bool isDark) {
    final cards = [
      _CardData(
        icon: Icons.calculate_rounded,
        label: 'Calculator',
        iconColor: AppColors.calculatorIcon,
        bgColor: AppColors.calculatorBg,
        bgColorDark: const Color(0xFF1E1630),
        screen: const CalculatorScreen(),
      ),
      _CardData(
        icon: Icons.access_time_filled_rounded,
        label: 'Clock',
        iconColor: AppColors.clockIcon,
        bgColor: AppColors.clockBg,
        bgColorDark: const Color(0xFF122218),
        screen: const ClockScreen(),
      ),
      _CardData(
        icon: Icons.flashlight_on_rounded,
        label: 'Flashlight',
        iconColor: AppColors.flashlightIcon,
        bgColor: AppColors.flashlightBg,
        bgColorDark: const Color(0xFF221A0E),
        screen: const FlashlightScreen(),
      ),
      _CardData(
        icon: Icons.check_circle_rounded,
        label: 'To-Do',
        iconColor: AppColors.todoIcon,
        bgColor: AppColors.todoBg,
        bgColorDark: const Color(0xFF0E1A2C),
        screen: const TodoScreen(),
      ),
      _CardData(
        icon: Icons.timer_rounded,
        label: 'Stopwatch',
        iconColor: AppColors.stopwatchIcon,
        bgColor: AppColors.stopwatchBg,
        bgColorDark: const Color(0xFF221212),
        screen: const StopwatchScreen(),
      ),
      _CardData(
        icon: Icons.language_rounded,
        label: 'Web Search',
        iconColor: AppColors.websearchIcon,
        bgColor: AppColors.websearchBg,
        bgColorDark: const Color(0xFF0E1A22),
        screen: const WebSearchScreen(),
      ),
      _CardData(
        icon: Icons.camera_alt_rounded,
        label: 'Camera',
        iconColor: const Color(0xFF5856D6),
        bgColor: const Color(0xFFEEEEFF),
        bgColorDark: const Color(0xFF18162E),
        screen: const CameraScreen(),
        hasNotification: false,
      ),
      _CardData(
        icon: Icons.chat_bubble_rounded,
        label: 'Messages',
        iconColor: const Color(0xFF34C759),
        bgColor: const Color(0xFFE6F8EC),
        bgColorDark: const Color(0xFF0E2218),
        screen: const MessagesScreen(),
        hasNotification: true,
      ),
    ];

    final card = cards[index];
    final iconBg = isDark ? card.bgColorDark : card.bgColor;
    // Subtle wrongness: first card icon is slightly oversized
    final iconSize = index == 0 ? 28.0 : 26.0;

    return _HomeCard(
      icon: card.icon,
      label: card.label,
      iconColor: card.iconColor,
      iconBg: iconBg,
      cardColor: cardColor,
      isDark: isDark,
      iconSize: iconSize,
      hasNotification: card.hasNotification,
      onTap: () => _openApp(card.label, card.screen),
    );
  }
}

class _CardData {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final Color bgColorDark;
  final Widget screen;
  final bool hasNotification;

  const _CardData({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.bgColorDark,
    required this.screen,
    this.hasNotification = false,
  });
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeToggle({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderDark : AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            size: 19,
            color: isDark ? const Color(0xFFFFD60A) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final Color cardColor;
  final bool isDark;
  final double iconSize;
  final bool hasNotification;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.cardColor,
    required this.isDark,
    required this.iconSize,
    this.hasNotification = false,
    required this.onTap,
  });

  @override
  State<_HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<_HomeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: AppRadius.card,
            boxShadow: _pressed ? AppShadows.cardPressed : AppShadows.card,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  RongIconContainer(
                    icon: widget.icon,
                    iconColor: widget.iconColor,
                    backgroundColor: widget.iconBg,
                    size: 54,
                  ),
                  if (widget.hasNotification)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.cardColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? AppColors.textDark : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
