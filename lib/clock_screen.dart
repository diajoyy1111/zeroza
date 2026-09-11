import 'dart:async';
import 'package:flutter/material.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;
  late Timer _yearTimer;
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
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    _yearTimer = Timer.periodic(const Duration(seconds: 3), (_) => _tickYear());
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

  void _tickYear() {
    setState(() {
      _year += (1 + (DateTime.now().millisecond % 5));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _yearTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timeStr =
        '$_hour:${_minute.toString().padLeft(2, '0')}:${_second.toString().padLeft(2, '0')}.${(_millisecond ~/ 10).toString().padLeft(2, '0')}';

    final dateStr = '$_year.${_month.toString().padLeft(2, '0')}.${_day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EPOCH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.2),
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w200,
                        color: const Color(0xFFE8A317).withValues(alpha: 0.7),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w100,
                        color: Colors.white.withValues(alpha: 0.95),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChip(label: 'YEAR', value: '$_year'),
                        const SizedBox(width: 16),
                        _InfoChip(label: 'MONTH', value: '$_month'),
                        const SizedBox(width: 16),
                        _InfoChip(label: 'DAY', value: '$_day'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4CAF50),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Time is relative',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.25),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
