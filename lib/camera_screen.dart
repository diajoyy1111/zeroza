import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isTaking = false;
  int _selectedMode = 0;
  final _modes = ['VIDEO', 'PHOTO', 'PORTRAIT', 'PANO'];

  bool _showBubble = false;

  // Local crack overlay
  late AnimationController _crackController;
  late Animation<double> _crackAnim;

  @override
  void initState() {
    super.initState();
    _crackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _crackAnim = CurvedAnimation(parent: _crackController, curve: Curves.easeOutCubic);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) setState(() => _isCameraReady = true);
      }
    } catch (_) {}
  }

  Future<void> _takePhoto() async {
    if (_isTaking) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _isTaking = true;
      _showBubble = false;
    });

    try {
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.takePicture();
      }
    } catch (_) {}

    // Play local crack
    _crackController.forward(from: 0.0);

    // After crack, show centered message
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _isTaking = false;
        _showBubble = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _crackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(flex: 5, child: _buildViewfinder(isDark)),
                    const SizedBox(height: 16),
                    _ModeSelector(
                      modes: _modes,
                      selectedIndex: _selectedMode,
                      isDark: isDark,
                      onChanged: (i) => setState(() => _selectedMode = i),
                    ),
                    const SizedBox(height: 20),
                    _CameraControls(
                      isDark: isDark,
                      onCapture: _takePhoto,
                      isTaking: _isTaking,
                    ),
                    const SizedBox(height: 16),
                    // Centered message after crack
                    AnimatedOpacity(
                      opacity: _showBubble ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: AnimatedSlide(
                        offset: _showBubble ? Offset.zero : const Offset(0, 0.3),
                        duration: const Duration(milliseconds: 400),
                        child: _showBubble
                            ? Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1630) : const Color(0xFFF5F0FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.accent.withValues(alpha: 0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(alpha: 0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      size: 18,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'THE BEAUTY YOU HAVE CAPTURED HAS CRACKED THE SCREEN',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accent,
                                          letterSpacing: 0.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Camera',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.flash_off_rounded, size: 20, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111118) : const Color(0xFFE8E6F0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isCameraReady && _controller != null)
              CameraPreview(_controller!)
            else
              _buildFallbackView(isDark),
            Positioned.fill(child: CustomPaint(painter: _GridPainter(isDark: isDark))),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: CustomPaint(painter: _FocusBracketsPainter()),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD60A).withValues(alpha: 0.7),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HDR',
                  style: TextStyle(
                    color: Color(0xFFFFD60A),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD60A).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Local crack overlay on viewfinder
            AnimatedBuilder(
              animation: _crackAnim,
              builder: (context, _) {
                if (_crackAnim.value <= 0) return const SizedBox.shrink();
                return Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _CrackPainter(progress: _crackAnim.value)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackView(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0E0E14), const Color(0xFF18161E), const Color(0xFF0E0E14)]
              : [const Color(0xFFD8D4E4), const Color(0xFFEAE7F2), const Color(0xFFD8D4E4)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_rounded, size: 40, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15)),
            const SizedBox(height: 8),
            Text('Camera preview', style: TextStyle(fontSize: 12, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2))),
          ],
        ),
      ),
    );
  }
}

// ─── LOCAL CRACK PAINTER ────────────────────────────────────────

class _CrackPainter extends CustomPainter {
  final double progress;
  _CrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // White flash
    final flashAlpha = progress < 0.3
        ? 0.4 * (progress / 0.3)
        : 0.4 * (1 - (progress - 0.3) / 0.7);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: flashAlpha.clamp(0.0, 1.0)),
    );

    // Crack lines
    final crackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * progress)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rng = Random(42);
    for (int i = 0; i < 18; i++) {
      final angle = (i / 18) * 2 * pi + rng.nextDouble() * 0.2;
      final maxLen = 60.0 + rng.nextDouble() * 140;
      final len = maxLen * progress;
      final end = Offset(center.dx + cos(angle) * len, center.dy + sin(angle) * len);
      canvas.drawLine(center, end, crackPaint);

      if (rng.nextDouble() < 0.6 && progress > 0.15) {
        final mid = Offset(center.dx + cos(angle) * len * 0.5, center.dy + sin(angle) * len * 0.5);
        final bAngle = angle + (rng.nextDouble() - 0.5) * 1.5;
        final bLen = len * 0.35;
        canvas.drawLine(mid, Offset(mid.dx + cos(bAngle) * bLen, mid.dy + sin(bAngle) * bLen), crackPaint);
      }
    }

    // Shatter fragments
    if (progress > 0.2) {
      final fragPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      for (int i = 0; i < 14; i++) {
        final a = rng.nextDouble() * 2 * pi;
        final r = 20.0 + rng.nextDouble() * 80;
        final pt = Offset(center.dx + cos(a) * r, center.dy + sin(a) * r);
        final sz = 5.0 + rng.nextDouble() * 10;
        canvas.drawRect(Rect.fromCenter(center: pt, width: sz, height: sz), fragPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CrackPainter old) => old.progress != progress;
}

// ─── GRID / FOCUS / CONTROLS ────────────────────────────────────

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(size.width * i / 3, 0), Offset(size.width * i / 3, size.height), paint);
      canvas.drawLine(Offset(0, size.height * i / 3), Offset(size.width, size.height * i / 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FocusBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 14.0;

    void drawCorner(Offset origin, int dx, int dy) {
      canvas.drawLine(origin + Offset(0, dy * len), origin, paint);
      canvas.drawLine(origin, origin + Offset(dx * len, 0), paint);
    }

    drawCorner(Offset.zero, 1, 1);
    drawCorner(Offset(size.width, 0), -1, 1);
    drawCorner(Offset(0, size.height), 1, -1);
    drawCorner(Offset(size.width, size.height), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ModeSelector extends StatelessWidget {
  final List<String> modes;
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _ModeSelector({required this.modes, required this.selectedIndex, required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(modes.length, (i) {
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => HapticFeedback.lightImpact().then((_) => onChanged(i)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  modes[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? const Color(0xFFFFD60A) : (isDark ? AppColors.textDarkSecondary : AppColors.textSecondary),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 16 : 0,
                  height: 2,
                  decoration: BoxDecoration(color: const Color(0xFFFFD60A), borderRadius: BorderRadius.circular(1)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _CameraControls extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCapture;
  final bool isTaking;

  const _CameraControls({required this.isDark, required this.onCapture, required this.isTaking});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.subtle,
          ),
          child: Icon(Icons.photo_library_outlined, size: 20, color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onCapture,
          child: AnimatedScale(
            scale: isTaking ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                  width: 3,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isTaking ? 48 : 56,
                  height: isTaking ? 48 : 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTaking ? Colors.grey : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.subtle,
          ),
          child: Icon(Icons.flip_camera_ios_rounded, size: 20, color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary),
        ),
      ],
    );
  }
}
