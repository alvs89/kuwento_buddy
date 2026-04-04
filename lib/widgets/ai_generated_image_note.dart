import 'package:flutter/material.dart';
import 'package:kuwentobuddy/theme.dart';

class AiGeneratedImageNote extends StatelessWidget {
  final String text;

  const AiGeneratedImageNote({
    super.key,
    this.text = 'AI-generated image',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = (isDark ? Colors.white : KuwentoColors.textSecondary)
        .withValues(alpha: 0.42);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: mutedColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.15,
            ),
          ),
        ),
      ),
    );
  }
}
