import 'dart:async';
import 'package:flutter/material.dart';

// ─── GLOBAL CAT CONTROLLER ──────────────────────────────────────

class RongCatController extends ChangeNotifier {
  bool _active = false;
  bool _finished = false;
  Timer? _timer;

  bool get isActive => _active;
  bool get isFinished => _finished;

  void startTimer() {
    _timer?.cancel();
    _active = false;
    _finished = false;
    _timer = Timer(const Duration(minutes: 1, seconds: 30), () {
      if (!_active && !_finished) {
        _active = true;
        notifyListeners();
      }
    });
  }

  void markFinished() {
    _finished = true;
    _active = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _active = false;
    _finished = false;
    notifyListeners();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final RongCatController rongCatController = RongCatController();

// ─── ROOT OVERLAY WRAPPER ───────────────────────────────────────

class RongOverlayWrapper extends StatefulWidget {
  final Widget child;
  const RongOverlayWrapper({super.key, required this.child});

  @override
  State<RongOverlayWrapper> createState() => _RongOverlayWrapperState();
}

class _RongOverlayWrapperState extends State<RongOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _catController;
  late Animation<double> _catSweep;
  bool _showBadLuck = false;

  @override
  void initState() {
    super.initState();

    _catController = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _catSweep = Tween<double>(begin: -0.15, end: 1.15).animate(
      CurvedAnimation(parent: _catController, curve: Curves.linear),
    );
    _catController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        rongCatController.markFinished();
        // Wait 3 seconds after cat finishes, then show black screen
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBadLuck = true);
        });
      }
    });

    rongCatController.addListener(_onCatChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) rongCatController.startTimer();
    });
  }

  void _onCatChange() {
    if (!mounted) return;
    if (rongCatController.isActive && !_catController.isAnimating) {
      setState(() => _showBadLuck = false);
      _catController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    rongCatController.removeListener(_onCatChange);
    _catController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Cat walk overlay — just the cat, no crack
        if (rongCatController.isActive)
          AnimatedBuilder(
            animation: _catController,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final catX = _catSweep.value * constraints.maxWidth;
                  final catY = constraints.maxHeight - 85;

                  return Stack(
                    children: [
                      // Black trail behind cat
                      Positioned(
                        left: 0,
                        top: 0,
                        width: (catX + 60).clamp(0.0, constraints.maxWidth),
                        height: constraints.maxHeight,
                        child: Container(color: Colors.black.withValues(alpha: 0.95)),
                      ),
                      // Cat
                      Positioned(
                        left: catX - 55,
                        top: catY - 45,
                        child: CustomPaint(
                          size: const Size(110, 90),
                          painter: _BlackCatPainter(),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

        // BAD LUCK screen — appears 3s after cat finishes
        if (_showBadLuck)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'BAD LUCK\nTRY AGAIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── BLACK CAT PAINTER ───────────────────────────────────────────

class _BlackCatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 4), width: size.width * 0.55, height: size.height * 0.42),
      paint,
    );

    final headCenter = Offset(cx + size.width * 0.26, cy - 4);
    canvas.drawCircle(headCenter, size.height * 0.22, paint);

    canvas.drawPath(
      Path()
        ..moveTo(headCenter.dx - 8, headCenter.dy - 14)
        ..lineTo(headCenter.dx - 2, headCenter.dy - 30)
        ..lineTo(headCenter.dx + 6, headCenter.dy - 14)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(headCenter.dx + 4, headCenter.dy - 14)
        ..lineTo(headCenter.dx + 12, headCenter.dy - 30)
        ..lineTo(headCenter.dx + 18, headCenter.dy - 14)
        ..close(),
      paint,
    );

    final eyePaint = Paint()..color = const Color(0xFF34C759);
    canvas.drawCircle(Offset(headCenter.dx - 2, headCenter.dy - 2), 2.2, eyePaint);
    canvas.drawCircle(Offset(headCenter.dx + 8, headCenter.dy - 2), 2.2, eyePaint);

    canvas.drawPath(
      Path()
        ..moveTo(cx - size.width * 0.22, cy + 2)
        ..quadraticBezierTo(cx - size.width * 0.38, cy - 20, cx - size.width * 0.30, cy - 32),
      Paint()..color = Colors.black..strokeWidth = 4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    canvas.drawRect(Rect.fromLTWH(cx - 12, cy + 14, 6, 16), paint);
    canvas.drawRect(Rect.fromLTWH(cx + 2, cy + 14, 6, 16), paint);
    canvas.drawRect(Rect.fromLTWH(cx + 16, cy + 14, 6, 16), paint);
    canvas.drawRect(Rect.fromLTWH(cx + 30, cy + 14, 6, 16), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
