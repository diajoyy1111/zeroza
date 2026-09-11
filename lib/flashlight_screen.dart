import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torch_light/torch_light.dart';
import 'app_theme.dart';

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> with SingleTickerProviderStateMixin {
  bool _isOn = false;
  bool _hasFlashlight = true;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
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
    HapticFeedback.mediumImpact();
    final newState = !_isOn;
    setState(() => _isOn = newState);

    if (_isOn) {
      _rippleController.repeat();
    } else {
      _rippleController.stop();
      _rippleController.reset();
    }

    if (_hasFlashlight) {
      try {
        // The RONG rule: toggle is inverted
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
    _rippleController.dispose();
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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      color: screenBright
          ? (isDark ? AppColors.backgroundDark : AppColors.background)
          : const Color(0xFF050508),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: screenBright
                      ? (isDark ? AppColors.textDark : AppColors.textPrimary)
                      : Colors.white38,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        final rippleValue = _rippleController.value;
                        return Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: _isOn
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFD60A).withValues(alpha: 0.12 * (1 - rippleValue)),
                                      blurRadius: 60 + 30 * rippleValue,
                                      spreadRadius: 15 + 15 * rippleValue,
                                    ),
                                  ]
                                : [],
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isOn
                                  ? const Color(0xFFFFD60A).withValues(alpha: 0.05)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : AppColors.border),
                            ),
                            child: Icon(
                              // Subtle wrongness: icon doesn't match state label
                              _isOn ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
                              size: 72,
                              color: _isOn
                                  ? const Color(0xFFFFD60A)
                                  : (isDark ? Colors.white24 : AppColors.textSecondary),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 44),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: screenBright
                            ? (isDark ? AppColors.textDark : AppColors.textPrimary)
                            : Colors.white70,
                        letterSpacing: 8,
                      ),
                      child: Text(_isOn ? 'ON' : 'OFF'),
                    ),
                    const SizedBox(height: 56),
                    GestureDetector(
                      onTap: _toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOn
                              ? AppColors.accent
                              : (isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border),
                          boxShadow: _isOn
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.power_settings_new_rounded,
                          size: 32,
                          color: _isOn ? Colors.white : Colors.white38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Tap to toggle',
                      style: TextStyle(
                        fontSize: 11,
                        color: screenBright
                            ? (isDark ? AppColors.textDarkSecondary : AppColors.textSecondary)
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
