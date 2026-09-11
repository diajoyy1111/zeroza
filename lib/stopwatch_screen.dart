import 'dart:async';
import 'package:flutter/material.dart';

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
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _elapsedMs = 0;
      _laps.clear();
    });
  }

  void _lap() {
    setState(() => _laps.add(_elapsedMs));
  }

  String _formatTime(int ms) {
    final hours = ms ~/ 3600000;
    final minutes = (ms ~/ 60000) % 60;
    final seconds = (ms ~/ 1000) % 60;
    final centiseconds = (ms ~/ 10) % 100;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0E0E12) : const Color(0xFFF5F5FA);
    final cardColor = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1F);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Stopwatch',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Timer display
            Expanded(
              flex: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular progress
                    SizedBox(
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
                              backgroundColor: (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isRunning ? const Color(0xFF9C2D2D) : const Color(0xFF6750A4),
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(_elapsedMs),
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w200,
                              color: textColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRunning ? 'Running at 2× speed' : 'Paused',
                      style: TextStyle(
                        fontSize: 13,
                        color: _isRunning ? const Color(0xFF9C2D2D) : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Laps
            if (_laps.isNotEmpty)
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      final lap = _laps[index];
                      final prev = index > 0 ? _laps[index - 1] : 0;
                      final diff = lap - prev;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lap ${_laps.length - index}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '+${_formatTime(diff)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            Text(
                              _formatTime(lap),
                              style: TextStyle(
                                fontSize: 14,
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
              ),
            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    label: 'Lap',
                    icon: Icons.flag_rounded,
                    color: Colors.grey,
                    onTap: _isRunning ? _lap : null,
                  ),
                  _ControlButton(
                    label: _isRunning ? 'Pause' : 'Start',
                    icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _isRunning ? const Color(0xFF9C2D2D) : const Color(0xFF006D3F),
                    onTap: _toggle,
                    primary: true,
                  ),
                  _ControlButton(
                    label: 'Reset',
                    icon: Icons.stop_rounded,
                    color: Colors.grey,
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

class _ControlButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: primary ? 72 : 56,
              height: primary ? 72 : 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary ? color : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[200]),
                boxShadow: primary
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: primary ? 36 : 28,
                color: primary ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
