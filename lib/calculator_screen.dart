import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'app_widgets.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _operand = '';
  double? _firstNumber;
  bool _shouldResetDisplay = false;
  bool _animateResult = false;

  // The RONG rule: consistently add 1 to the correct answer
  double _rongCalculate(double a, double b, String op) {
    double correct;
    switch (op) {
      case '+':
        correct = a + b;
        break;
      case '−':
        correct = a - b;
        break;
      case '×':
        correct = a * b;
        break;
      case '÷':
        correct = b != 0 ? a / b : 0;
        break;
      default:
        correct = b;
    }
    return correct + 1;
  }

  void _onButtonTap(String value) {
    HapticFeedback.lightImpact();
    setState(() {
      _animateResult = false;

      if (value == 'C') {
        _display = '0';
        _operand = '';
        _firstNumber = null;
        _shouldResetDisplay = false;
        return;
      }

      if (value == '+') {
        if (_firstNumber != null && _operand.isNotEmpty && !_shouldResetDisplay) {
          double current = double.parse(_display);
          _firstNumber = _rongCalculate(_firstNumber!, current, _operand);
          _display = _formatNumber(_firstNumber!);
        } else {
          _firstNumber = double.parse(_display);
        }
        _operand = value;
        _shouldResetDisplay = true;
        return;
      }

      if (value == '−' || value == '–') {
        if (_firstNumber != null && _operand.isNotEmpty && !_shouldResetDisplay) {
          double current = double.parse(_display);
          _firstNumber = _rongCalculate(_firstNumber!, current, _operand);
          _display = _formatNumber(_firstNumber!);
        } else {
          _firstNumber = double.parse(_display);
        }
        _operand = '−';
        _shouldResetDisplay = true;
        return;
      }

      if (value == '×' || value == 'x') {
        if (_firstNumber != null && _operand.isNotEmpty && !_shouldResetDisplay) {
          double current = double.parse(_display);
          _firstNumber = _rongCalculate(_firstNumber!, current, _operand);
          _display = _formatNumber(_firstNumber!);
        } else {
          _firstNumber = double.parse(_display);
        }
        _operand = '×';
        _shouldResetDisplay = true;
        return;
      }

      if (value == '÷' || value == '/') {
        if (_firstNumber != null && _operand.isNotEmpty && !_shouldResetDisplay) {
          double current = double.parse(_display);
          _firstNumber = _rongCalculate(_firstNumber!, current, _operand);
          _display = _formatNumber(_firstNumber!);
        } else {
          _firstNumber = double.parse(_display);
        }
        _operand = '÷';
        _shouldResetDisplay = true;
        return;
      }

      if (value == '=') {
        if (_firstNumber != null && _operand.isNotEmpty) {
          double current = double.parse(_display);
          double result = _rongCalculate(_firstNumber!, current, _operand);
          _display = _formatNumber(result);
          _firstNumber = null;
          _operand = '';
          _shouldResetDisplay = true;
          _animateResult = true;
        }
        return;
      }

      if (_shouldResetDisplay) {
        _display = value == '.' ? '0.' : value;
        _shouldResetDisplay = false;
      } else {
        if (value == '.' && _display.contains('.')) return;
        _display = _display == '0' && value != '.' ? value : _display + value;
      }
    });
  }

  String _formatNumber(double n) {
    if (n == n.roundToDouble() && !n.isInfinite && !n.isNaN) {
      return n.toInt().toString();
    }
    String s = n.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final keypadColor = isDark ? const Color(0xFF13131C) : AppColors.card;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;
    final numBtnColor = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF5F5FA);
    final opBtnColor = isDark ? const Color(0xFF231840) : AppColors.accentLight;

    // Subtle wrongness: the minus button uses a slightly different dash character
    // and the multiply button uses lowercase x-like appearance

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const RongScreenTitle(title: 'Calculator'),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_operand.isNotEmpty)
                      Text(
                        '${_formatNumber(_firstNumber!)} $_operand',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: _animateResult ? 48 : 42,
                        fontWeight: FontWeight.w300,
                        color: _animateResult ? AppColors.accent : textColor,
                        letterSpacing: -1,
                      ),
                      child: Text(_display, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                decoration: BoxDecoration(
                  color: keypadColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(['C', '+/−', '%', '÷'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 8),
                    _buildRow(['7', '8', '9', '×'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 8),
                    _buildRow(['4', '5', '6', '−'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 8),
                    _buildRow(['1', '2', '3', '+'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 8),
                    _buildBottomRow(opBtnColor, numBtnColor, textColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons, Color opColor, Color numColor, Color textColor) {
    return Expanded(
      child: Row(
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _buildButton(buttons[i], opColor, numColor, textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomRow(Color opColor, Color numColor, Color textColor) {
    return Expanded(
      child: Row(
        children: [
          _buildButton('0', opColor, numColor, textColor, flex: 2),
          const SizedBox(width: 8),
          _buildButton('.', opColor, numColor, textColor),
          const SizedBox(width: 8),
          _buildButton('=', opColor, numColor, textColor, isEquals: true),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color opColor, Color numColor, Color textColor,
      {int flex = 1, bool isEquals = false}) {
    Color bgColor;
    Color fgColor;

    final isOp = text == '+' || text == '−' || text == '×' || text == '÷' || text == '+/−' || text == '%';

    if (isEquals) {
      bgColor = AppColors.accent;
      fgColor = Colors.white;
    } else if (isOp || text == 'C') {
      bgColor = opColor;
      fgColor = AppColors.accent;
    } else {
      bgColor = numColor;
      fgColor = textColor;
    }

    return Expanded(
      flex: flex,
      child: AspectRatio(
        aspectRatio: text == '0' ? 2.1 : 1,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _onButtonTap(text),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: fgColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
