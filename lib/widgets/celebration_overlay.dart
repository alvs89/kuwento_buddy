import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// Celebration overlay with confetti and fireworks for story completion
class CelebrationOverlay extends StatefulWidget {
  final int starsEarned;
  final double comprehensionScore;
  final VoidCallback onReadAgain;
  final VoidCallback onActivity;
  final VoidCallback onBackToLibrary;
  final String storyTitle;

  const CelebrationOverlay({
    super.key,
    required this.starsEarned,
    required this.comprehensionScore,
    required this.onReadAgain,
    required this.onActivity,
    required this.onBackToLibrary,
    required this.storyTitle,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _starController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _starAnimation;
  late final bool _isZeroOutcome;
  late final String _supportiveTitle;
  final List<String> _supportiveMessages = const [
    "It's okay, Buddy! Let's bounce back. 🤜🤛",
    'Try again? You can do it! 💪',
    "Don't give up, read and learn again! 📚✨",
  ];

  @override
  void initState() {
    super.initState();

    _isZeroOutcome = widget.starsEarned == 0 && widget.comprehensionScore == 0;
    _supportiveTitle = _supportiveMessages[math.Random().nextInt(
      _supportiveMessages.length,
    )];

    // Confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Scale animation for dialog
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Star animation
    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOutBack,
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _starController.forward();
      if (!_isZeroOutcome) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background overlay
        GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.black.withValues(alpha: 0.75),
          ),
        ),

        if (!_isZeroOutcome) ...[
          // Confetti from top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              shouldLoop: false,
              colors: [
                KuwentoColors.buddyHappy,
                KuwentoColors.buddyThinking,
                KuwentoColors.softCoral,
                KuwentoColors.pastelBlue,
                KuwentoColors.buddyEncouraging,
                Colors.white,
              ],
              createParticlePath: (size) => _drawStar(size),
            ),
          ),

          // Confetti from left
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -math.pi / 4,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.03,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: [
                KuwentoColors.buddyHappy,
                KuwentoColors.buddyThinking,
                KuwentoColors.softCoral,
              ],
            ),
          ),

          // Confetti from right
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3 * math.pi / 4,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.03,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: [
                KuwentoColors.pastelBlue,
                KuwentoColors.buddyEncouraging,
                Colors.white,
              ],
            ),
          ),
        ],

        // Main celebration dialog
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: isDark ? KuwentoColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: KuwentoColors.buddyHappy.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: _isZeroOutcome
                        ? const Offset(0, -9)
                        : const Offset(0, -12),
                    child: BuddyCompanion(
                      state: _isZeroOutcome
                          ? BuddyState.sympathetic
                          : BuddyState.happy,
                      size: 100, // adjust height
                      showSpeechBubble: false,
                    ),
                  ),
                  SizedBox(
                    height: _isZeroOutcome ? AppSpacing.xl : AppSpacing.lg,
                  ),

                  // Title (keep supportive messages on a single line)
                  _isZeroOutcome
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _supportiveTitle,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: KuwentoColors.buddyEncouraging,
                                ),
                          ),
                        )
                      : Text(
                          'Magaling! 🎉',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: KuwentoColors.buddyHappy,
                              ),
                        ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Story Complete!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              isDark ? Colors.white : KuwentoColors.textPrimary,
                        ),
                  ),

                  SizedBox(
                    height: _isZeroOutcome ? AppSpacing.lg : AppSpacing.md,
                  ),

                  // Stars earned with animation
                  AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (context, child) {
                      double _starFill(int index) {
                        const epsilon = 1e-6;
                        final score = widget.comprehensionScore.clamp(0, 100);
                        // Normalize score to a 0–3 scale, then find how much of this star is filled.
                        final normalized = (score / 100) * 3;
                        final value = normalized - index;

                        if (value >= 1 - epsilon) return 1.0; // full star
                        if (value >= 0.5 - epsilon) return 0.5; // half star
                        return value.clamp(0.0, 1.0);
                      }

                      IconData _starIcon(double fill) {
                        if (fill >= 1) return Icons.star;
                        if (fill >= 0.5) return Icons.star_half;
                        return Icons.star_border;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final fill = _starFill(index);
                          final delay = index * 0.2;
                          final animValue =
                              (_starAnimation.value - delay).clamp(0.0, 1.0);

                          return Transform.scale(
                            scale: fill > 0 ? animValue : 1.0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                _starIcon(fill),
                                color: KuwentoColors.buddyThinking,
                                size: 48,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Comprehension score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: KuwentoColors.pastelBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology,
                          color: KuwentoColors.pastelBlue,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Comprehension: ${widget.comprehensionScore.toStringAsFixed(0)}%',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: KuwentoColors.pastelBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onReadAgain,
                          icon: const Icon(Icons.replay, size: 18),
                          label: const Text('Read Again'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: KuwentoColors.pastelBlue,
                            side: BorderSide(color: KuwentoColors.pastelBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onActivity,
                          icon: const Icon(Icons.extension,
                              size: 18, color: Colors.white),
                          label: const Text(
                            'Activity',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KuwentoColors.buddyHappy,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onBackToLibrary,
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white54
                              : KuwentoColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    final center = size.width / 2;
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;

      if (i == 0) {
        path.moveTo(
          center + outerRadius * math.cos(outerAngle),
          center + outerRadius * math.sin(outerAngle),
        );
      } else {
        path.lineTo(
          center + outerRadius * math.cos(outerAngle),
          center + outerRadius * math.sin(outerAngle),
        );
      }

      path.lineTo(
        center + innerRadius * math.cos(innerAngle),
        center + innerRadius * math.sin(innerAngle),
      );
    }

    path.close();
    return path;
  }
}
