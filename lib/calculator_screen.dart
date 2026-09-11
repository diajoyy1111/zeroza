import 'package:flutter/material.dart';

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
    setState(() {
      _animateResult = false;

      if (value == 'C') {
        _display = '0';
        _operand = '';
        _firstNumber = null;
        _shouldResetDisplay = false;
        return;
      }

      if (value == '+' || value == '−' || value == '×' || value == '÷') {
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
    final bgColor = isDark ? const Color(0xFF0E0E12) : const Color(0xFFF5F5FA);
    final keypadColor = isDark ? const Color(0xFF1A1A24) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1B1F);
    final numBtnColor = isDark ? const Color(0xFF252530) : const Color(0xFFF5F5FA);
    final opBtnColor = isDark ? const Color(0xFF2E1F50) : const Color(0xFFE8E0F0);

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
                    'Calculator',
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
            // Display
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_operand.isNotEmpty)
                      Text(
                        '${_formatNumber(_firstNumber!)} $_operand',
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      ),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: _animateResult ? 52 : 44,
                        fontWeight: FontWeight.w300,
                        color: _animateResult
                            ? const Color(0xFF6750A4)
                            : textColor,
                      ),
                      child: Text(_display, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            // Keypad
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: keypadColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _buildRow(['C', '÷', '×', '−'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 10),
                    _buildRow(['7', '8', '9', '+'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 10),
                    _buildRow(['4', '5', '6', '−'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 10),
                    _buildRow(['1', '2', '3', '×'], opBtnColor, numBtnColor, textColor),
                    const SizedBox(height: 10),
                    _buildWideBottomRow(opBtnColor, numBtnColor, textColor),
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
            if (i > 0) const SizedBox(width: 10),
            _buildButton(buttons[i], opColor, numColor, textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildWideBottomRow(Color opColor, Color numColor, Color textColor) {
    return Expanded(
      child: Row(
        children: [
          _buildButton('0', opColor, numColor, textColor, flex: 2),
          const SizedBox(width: 10),
          _buildButton('.', opColor, numColor, textColor),
          const SizedBox(width: 10),
          _buildButton('=', opColor, numColor, textColor, isEquals: true),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color opColor, Color numColor, Color textColor,
      {int flex = 1, bool isEquals = false}) {
    Color bgColor;
    Color fgColor;

    if (isEquals) {
      bgColor = const Color(0xFF6750A4);
      fgColor = Colors.white;
    } else if (text == 'C' || text == '÷' || text == '×' || text == '−' || text == '+') {
      bgColor = opColor;
      fgColor = const Color(0xFF6750A4);
    } else {
      bgColor = numColor;
      fgColor = textColor;
    }

    return Expanded(
      flex: flex,
      child: AspectRatio(
        aspectRatio: 1,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _onButtonTap(text),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 22,
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
