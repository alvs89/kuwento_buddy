import 'package:flutter/material.dart';
import 'package:kuwentobuddy/theme.dart';

class ParentalGate extends StatefulWidget {
  final String title;
  final String message;

  const ParentalGate({
    super.key,
    this.title = 'Adult confirmation required',
    this.message =
        'This action changes a reading profile. Please confirm before continuing.',
  });

  /// Helper to show the gate as a modal
  static Future<bool?> show(
    BuildContext context, {
    String title = 'Adult confirmation required',
    String message =
        'This action changes a reading profile. Please confirm before continuing.',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (c) => ParentalGate(
        title: title,
        message: message,
      ),
    );
  }

  @override
  State<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends State<ParentalGate> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: KuwentoColors.pastelBlue.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: KuwentoColors.pastelBlue,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: KuwentoColors.textPrimary,
                ),
          ),
        ],
      ),
      content: Text(
        widget.message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: KuwentoColors.textSecondary,
              height: 1.45,
            ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
