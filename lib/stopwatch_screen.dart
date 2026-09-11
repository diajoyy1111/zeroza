import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'app_widgets.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  late Timer _timer;
  int _elapsedMs = 0;
  bool _isRunning = false;
  final List<int> _laps = [];

  // The RONG rule: stopwatch runs at 2x speed
  void _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() => _elapsedMs += 20);
    });
  }

  void _stop() {
    _timer.cancel();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _start();
      } else {
        _stop();
      }
    });
  }

  void _reset() {
    HapticFeedback.heavyImpact();
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _elapsedMs = 0;
      _laps.clear();
    });
  }

  void _lap() {
    HapticFeedback.lightImpact();
    setState(() => _laps.add(_elapsedMs));
  }

  // Subtle wrongness: format uses non-standard separator placement
  // and includes an extra leading zero on hours
  String _formatTime(int ms) {
    final hours = ms ~/ 3600000;
    final minutes = (ms ~/ 60000) % 60;
    final seconds = (ms ~/ 1000) % 60;
    final centiseconds = (ms ~/ 10) % 100;
    // Wrong: hours always show 3 digits when >= 10
    final hourStr = hours >= 10 ? hours.toString().padLeft(3, '0') : hours.toString().padLeft(2, '0');
    return '$hourStr:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardColor = isDark ? AppColors.cardDark : AppColors.card;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const RongScreenTitle(title: 'Stopwatch'),
            Expanded(
              flex: 4,
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: (_elapsedMs % 60000) / 60000,
                          strokeWidth: 4,
                          backgroundColor: (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isRunning ? AppColors.stopwatchIcon : AppColors.accent,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_elapsedMs),
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w200,
                              color: textColor,
                              letterSpacing: -0.5,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRunning ? 'Running at 2× speed' : 'Paused',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isRunning ? AppColors.stopwatchIcon : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_laps.isNotEmpty)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: _laps.length,
                          itemBuilder: (context, index) {
                            final lap = _laps[index];
                            final prev = index > 0 ? _laps[index - 1] : 0;
                            final diff = lap - prev;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Lap ${_laps.length - index}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    '+${_formatTime(diff)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  Text(
                                    _formatTime(lap),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    label: 'Lap',
                    icon: Icons.flag_rounded,
                    color: AppColors.textSecondary,
                    onTap: _isRunning ? _lap : null,
                  ),
                  _ControlButton(
                    label: _isRunning ? 'Pause' : 'Start',
                    icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isRunning ? AppColors.stopwatchIcon : AppColors.clockIcon,
                    onTap: _toggle,
                    primary: true,
                  ),
                  _ControlButton(
                    label: 'Reset',
                    icon: Icons.stop_rounded,
                    color: AppColors.textSecondary,
                    onTap: _elapsedMs > 0 ? _reset : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool primary;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.primary = false,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = widget.primary ? 68.0 : 52.0;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.primary
                    ? widget.color
                    : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F0F5)),
                boxShadow: widget.primary
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.25),
                          blurRadius: 14,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                widget.icon,
                size: widget.primary ? 32 : 24,
                color: widget.primary ? Colors.white : widget.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
