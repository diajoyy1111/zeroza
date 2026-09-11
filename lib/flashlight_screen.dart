import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  bool _isOn = false;
  bool _hasFlashlight = true;

  @override
  void initState() {
    super.initState();
    _checkFlashlight();
  }

  Future<void> _checkFlashlight() async {
    try {
      _hasFlashlight = await TorchLight.isTorchAvailable();
    } catch (_) {
      _hasFlashlight = false;
    }
  }

  Future<void> _toggle() async {
    final newState = !_isOn;
    setState(() => _isOn = newState);

    if (_hasFlashlight) {
      try {
        if (newState) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    if (_hasFlashlight) {
      TorchLight.disableTorch().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool screenBright = !_isOn;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: screenBright
          ? (isDark ? const Color(0xFF1A1A24) : const Color(0xFFFFFDF5))
          : const Color(0xFF0A0A0A),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: screenBright
                      ? (isDark ? Colors.white54 : Colors.grey[600])
                      : Colors.white30,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glow
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _isOn
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
                                  blurRadius: 80,
                                  spreadRadius: 30,
                                ),
                              ]
                            : [],
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOn
                              ? const Color(0xFFFFD93D).withValues(alpha: 0.08)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.grey[200]),
                        ),
                        child: Icon(
                          _isOn ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                          size: 80,
                          color: _isOn
                              ? const Color(0xFFFFD93D)
                              : (isDark ? Colors.white24 : Colors.grey[400]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      _isOn ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: screenBright
                            ? (isDark ? Colors.white70 : const Color(0xFF1C1B1F))
                            : Colors.white70,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTap: _toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOn
                              ? const Color(0xFF6750A4)
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[300]),
                          boxShadow: _isOn
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6750A4).withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.power_settings_new_rounded,
                          size: 36,
                          color: _isOn ? Colors.white : Colors.white38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tap to toggle',
                      style: TextStyle(
                        fontSize: 12,
                        color: screenBright
                            ? (isDark ? Colors.white24 : Colors.grey[400])
                            : Colors.white24,
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
