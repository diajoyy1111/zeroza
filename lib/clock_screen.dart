import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'app_widgets.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;

  // The RONG rule: time is impossible — hours go to 99, minutes to 99, seconds to 99
  // and the year ticks erratically
  int _year = 2026;
  int _month = 9;
  int _day = 11;
  int _hour = 10;
  int _minute = 58;
  int _second = 0;
  int _millisecond = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    setState(() {
      _millisecond += 37;
      if (_millisecond >= 1000) {
        _millisecond -= 1000;
        _second++;
        if (_second >= 99) {
          _second = 0;
          _minute++;
          if (_minute >= 99) {
            _minute = 0;
            _hour++;
            if (_hour >= 99) {
              _hour = 0;
              _day++;
              if (_day > 99) {
                _day = 1;
                _month++;
                if (_month > 99) {
                  _month = 1;
                  _year++;
                }
              }
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '$_hour:${_minute.toString().padLeft(2, '0')}:${_second.toString().padLeft(2, '0')}.${(_millisecond ~/ 10).toString().padLeft(2, '0')}';
    final dateStr =
        '$_year.${_month.toString().padLeft(2, '0')}.${_day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      body: SafeArea(
        child: Column(
          children: [
            const RongBackButton(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'E P O C H',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.12),
                        letterSpacing: 10,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w200,
                        color: const Color(0xFFFF9F0A).withValues(alpha: 0.5),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.w100,
                        color: Colors.white.withValues(alpha: 0.92),
                        letterSpacing: 2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChip(label: 'YEAR', value: '$_year'),
                        const SizedBox(width: 10),
                        _InfoChip(label: 'MONTH', value: '$_month'),
                        const SizedBox(width: 10),
                        _InfoChip(label: 'DAY', value: '$_day'),
                      ],
                    ),
                    const SizedBox(height: 52),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulse = (sin(_pulseController.value * 2 * pi) + 1) / 2;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.lerp(
                                    const Color(0xFF34C759),
                                    const Color(0xFF30D158),
                                    pulse,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.lerp(
                                        const Color(0xFF34C759).withValues(alpha: 0.3),
                                        const Color(0xFF30D158).withValues(alpha: 0.6),
                                        pulse,
                                      )!,
                                      blurRadius: 6 + 3 * pulse,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Time is relative',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.18 + 0.04 * pulse),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.2),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
