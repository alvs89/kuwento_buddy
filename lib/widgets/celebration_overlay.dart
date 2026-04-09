import 'dart:async';
import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
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
  static const double _celebrationSoundVolume = 1.0;
  static const String _celebrationSoundAsset =
      'audio/Celebration_Sound_Effect.wav';

  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _starController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _starAnimation;
  late final AudioPlayer _celebrationPlayer;
  late final bool _isZeroOutcome;
  late final bool _hasCelebrationReward;
  late final String _supportiveTitle;
  late final AudioContext _celebrationAudioContext;
  final List<String> _supportiveMessages = const [
    "It's okay, Buddy! Let's bounce back. 🤜🤛",
    'Try again? You can do it! 💪',
    "Don't give up, read and learn again! 📚✨",
  ];

  @override
  void initState() {
    super.initState();

    _isZeroOutcome = widget.starsEarned == 0;
    _hasCelebrationReward = widget.starsEarned > 0;
    _supportiveTitle =
        _supportiveMessages[math.Random().nextInt(_supportiveMessages.length)];
    _celebrationAudioContext = AudioContextConfig(
      route: AudioContextConfigRoute.speaker,
      focus: AudioContextConfigFocus.gain,
      respectSilence: false,
    ).build();
    _celebrationPlayer = AudioPlayer();
    unawaited(_prepareCelebrationSound());

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

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
      if (_hasCelebrationReward) {
        _confettiController.play();
        unawaited(_playCelebrationSound());
      }
    });
  }

  Future<void> _playCelebrationSound() async {
    try {
      await _celebrationPlayer.stop();
      await AudioPlayer.global.setAudioContext(_celebrationAudioContext);
      await _celebrationPlayer.play(
        AssetSource(_celebrationSoundAsset),
        volume: _celebrationSoundVolume,
        ctx: _celebrationAudioContext,
        mode: PlayerMode.mediaPlayer,
      );
    } catch (error) {
      debugPrint('Celebration sound failed to play: $error');
    }
  }

  Future<void> _prepareCelebrationSound() async {
    try {
      await _celebrationPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _celebrationPlayer.setAudioContext(_celebrationAudioContext);
      await _celebrationPlayer.setReleaseMode(ReleaseMode.stop);
      await _celebrationPlayer.setVolume(_celebrationSoundVolume);
      await _celebrationPlayer.setSource(AssetSource(_celebrationSoundAsset));
    } catch (error) {
      debugPrint('Celebration sound failed to prepare: $error');
    }
  }

  @override
  void dispose() {
    unawaited(_celebrationPlayer.dispose());
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
          child: Container(color: Colors.black.withValues(alpha: 0.75)),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                  if (_isZeroOutcome)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _supportiveTitle,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
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
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            _successTitle,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: KuwentoColors.buddyHappy,
                                ),
                          ),
                        ),
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
                      final starCount = widget.starsEarned.clamp(0, 3);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final fill = _starFillForIndex(starCount, index);
                          final delay = index * 0.2;
                          final animValue =
                              (_starAnimation.value - delay).clamp(0.0, 1.0);

                          return _buildScoreStar(
                            fill: fill,
                            scale: fill > 0 ? animValue : 1.0,
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
                          icon: const Icon(
                            Icons.extension,
                            size: 18,
                            color: Colors.white,
                          ),
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

  double _starFillForIndex(int starsEarned, int index) {
    return index < starsEarned ? 1.0 : 0.0;
  }

  String get _successTitle {
    switch (widget.starsEarned.clamp(0, 3)) {
      case 1:
        return 'Magaling! ⭐';
      case 2:
        return 'Great Job! 🌟';
      case 3:
        return 'Excellent! 🏆';
      default:
        return 'Magaling! ⭐';
    }
  }

  Widget _buildScoreStar({required double fill, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: 48,
          height: 48,
          child: CustomPaint(
            painter: _ScoreStarPainter(pathBuilder: _drawStar, fill: fill),
          ),
        ),
      ),
    );
  }
}

class _ScoreStarPainter extends CustomPainter {
  final Path Function(Size) pathBuilder;
  final double fill;

  const _ScoreStarPainter({required this.pathBuilder, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final starPath = pathBuilder(size);
    final clampedFill = fill.clamp(0.0, 1.0);

    final basePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFF59D).withValues(alpha: 0.12);
    canvas.drawPath(starPath, basePaint);

    if (clampedFill > 0) {
      canvas.save();
      canvas.clipPath(starPath);
      canvas.clipRect(
        Rect.fromLTWH(0, 0, size.width * clampedFill, size.height),
      );
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF59D), Color(0xFFFFC107)],
        ).createShader(Offset.zero & size);
      canvas.drawPath(starPath, fillPaint);
      canvas.restore();
    }

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.55);
    canvas.drawPath(starPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreStarPainter oldDelegate) {
    return oldDelegate.fill != fill;
  }
}
