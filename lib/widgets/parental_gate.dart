import 'package:flutter/material.dart';
import 'package:kuwentobuddy/theme.dart';
import 'dart:math';

class ParentalGate extends StatefulWidget {
  const ParentalGate({super.key});

  /// Helper to show the gate as a modal
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => const ParentalGate(),
    );
  }

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  late final int _num1;
  late final int _num2;
  late final int _expectedAnswer;
  String _input = '';

  @override
  void initState() {
    super.initState();
    final random = Random();
    _num1 = random.nextInt(9) + 2; // 2 to 10
    _num2 = random.nextInt(9) + 2; // 2 to 10
    _expectedAnswer = _num1 * _num2;
  }

  void _onNumberTap(String num) {
    if (_input.length < 3) {
      setState(() => _input += num);
      _checkAnswer();
    }
  }

  void _onClear() {
    if (_input.isNotEmpty) {
      setState(() => _input = _input.substring(0, _input.length - 1));
    }
  }

  void _checkAnswer() {
    if (_input.length == _expectedAnswer.toString().length) {
      if (int.tryParse(_input) == _expectedAnswer) {
        Navigator.pop(context, true);
      } else {
        setState(() => _input = '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect. Try again!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ask a grown-up to help!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KuwentoColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'What is $_num1 × $_num2?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KuwentoColors.surfaceLight,
                    border: Border.all(color: KuwentoColors.textMuted),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _input.isEmpty ? '?' : _input,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCustomKeypad(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomKeypad() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
        _buildKeypadButton('C',
            color: Colors.grey[300]!, textCol: Colors.black),
        _buildKeypadButton('0'),
      ],
    );
  }

  Widget _buildKeypadButton(String label,
      {Color? color, Color textCol = Colors.white}) {
    return InkWell(
      onTap: () => label == 'C' ? _onClear() : _onNumberTap(label),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color ?? KuwentoColors.pastelBlue,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
      ),
    );
  }
}
