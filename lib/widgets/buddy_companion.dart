import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuwentobuddy/theme.dart';

/// Buddy's emotional states during interactions
enum BuddyState {
  idle,
  thinking,
  happy,
  encouraging,
  sympathetic,
  waving,
  cheering
}

/// Animated buddy companion widget - Full body robot character
/// Positioned at bottom right for natural thumb zone access
class BuddyCompanion extends StatefulWidget {
  final BuddyState state;
  final String? message;
  final VoidCallback? onTap;
  final double size;
  final bool showSpeechBubble;

  const BuddyCompanion({
    super.key,
    this.state = BuddyState.idle,
    this.message,
    this.onTap,
    this.size = 120,
    this.showSpeechBubble = true,
  });

  @override
  State<BuddyCompanion> createState() => _BuddyCompanionState();
}

class _BuddyCompanionState extends State<BuddyCompanion>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _headTiltController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _headTiltAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _handleStateChange();
  }

  void _initAnimations() {
    // Bounce animation for happy state
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Pulse animation for thinking state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for waving state
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: -0.2, end: 0.3).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Head tilt animation
    _headTiltController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _headTiltAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _headTiltController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BuddyCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _handleStateChange();
    }
  }

  void _handleStateChange() {
    // Stop all animations first
    _bounceController.stop();
    _bounceController.reset();
    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();
    _headTiltController.stop();

    switch (widget.state) {
      case BuddyState.happy:
        HapticFeedback.lightImpact();
        _bounceController.repeat(reverse: true);
        break;
      case BuddyState.thinking:
        _pulseController.repeat(reverse: true);
        _headTiltController.repeat(reverse: true);
        break;
      case BuddyState.encouraging:
        HapticFeedback.lightImpact();
        _pulseController.repeat(reverse: true);
        break;
      case BuddyState.sympathetic:
        _headTiltController.repeat(reverse: true);
        break;
      case BuddyState.waving:
        _waveController.repeat(reverse: true);
        break;
      case BuddyState.cheering:
        HapticFeedback.mediumImpact();
        _bounceController.repeat(reverse: true);
        _waveController.repeat(reverse: true);
        break;
      case BuddyState.idle:
        _headTiltController.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _headTiltController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.message != null && widget.showSpeechBubble) ...[
            BuddySpeechBubble(
              message: widget.message!,
              state: widget.state,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AnimatedBuilder(
            animation: Listenable.merge([
              _bounceAnimation,
              _pulseAnimation,
              _headTiltAnimation,
            ]),
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.scale(
                scale: widget.state == BuddyState.thinking ||
                        widget.state == BuddyState.encouraging
                    ? _pulseAnimation.value
                    : 1.0,
                child: child,
              ),
            ),
            child: _BuddyCharacter(
              size: widget.size,
              state: widget.state,
              waveAnimation: _waveAnimation,
              headTiltAnimation: _headTiltAnimation,
            ),
          ),
        ],
      ),
    );
  }
}

/// The actual buddy character with body parts
class _BuddyCharacter extends StatelessWidget {
  final double size;
  final BuddyState state;
  final Animation<double> waveAnimation;
  final Animation<double> headTiltAnimation;

  const _BuddyCharacter({
    required this.size,
    required this.state,
    required this.waveAnimation,
    required this.headTiltAnimation,
  });

  Color get _primaryColor {
    switch (state) {
      case BuddyState.idle:
        return KuwentoColors.pastelBlue;
      case BuddyState.thinking:
        return KuwentoColors.buddyThinking;
      case BuddyState.happy:
        return KuwentoColors.buddyHappy;
      case BuddyState.encouraging:
        return KuwentoColors.buddyEncouraging;
      case BuddyState.sympathetic:
        return KuwentoColors.buddySympathetic;
      case BuddyState.waving:
        return KuwentoColors.pastelBlue;
      case BuddyState.cheering:
        return KuwentoColors.buddyHappy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Positioned(
            bottom: 0,
            child: _buildBody(),
          ),
          // Left Arm
          Positioned(
            left: size * 0.08,
            bottom: size * 0.35,
            child: _buildArm(isLeft: true),
          ),
          // Right Arm (animated for waving)
          Positioned(
            right: size * 0.08,
            bottom: size * 0.35,
            child: AnimatedBuilder(
              animation: waveAnimation,
              builder: (context, child) {
                final angle =
                    state == BuddyState.waving ? waveAnimation.value : 0.0;
                return Transform.rotate(
                  angle: angle,
                  alignment: Alignment.bottomCenter,
                  child: child,
                );
              },
              child: _buildArm(isLeft: false),
            ),
          ),
          // Head
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: headTiltAnimation,
              builder: (context, child) => Transform.rotate(
                angle: headTiltAnimation.value,
                child: child,
              ),
              child: _buildHead(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHead() {
    return Container(
      width: size * 0.65,
      height: size * 0.55,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Eyes
          Positioned(
            top: size * 0.12,
            left: size * 0.1,
            child: _buildEye(isLeft: true),
          ),
          Positioned(
            top: size * 0.12,
            right: size * 0.1,
            child: _buildEye(isLeft: false),
          ),
          // Mouth
          Positioned(
            bottom: size * 0.08,
            left: 0,
            right: 0,
            child: Center(child: _buildMouth()),
          ),
          // Antenna
          Positioned(
            top: -size * 0.08,
            left: 0,
            right: 0,
            child: Center(child: _buildAntenna()),
          ),
        ],
      ),
    );
  }

  Widget _buildEye({required bool isLeft}) {
    final eyeSize = size * 0.12;
    final pupilSize = eyeSize * 0.5;

    return Container(
      width: eyeSize,
      height: eyeSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: state == BuddyState.happy ? eyeSize * 0.3 : pupilSize,
          height: state == BuddyState.happy ? eyeSize * 0.15 : pupilSize,
          decoration: BoxDecoration(
            color: KuwentoColors.textPrimary,
            borderRadius: state == BuddyState.happy
                ? BorderRadius.circular(2)
                : BorderRadius.circular(pupilSize),
          ),
        ),
      ),
    );
  }

  Widget _buildMouth() {
    final mouthWidth = size * 0.25;
    final mouthHeight = size * 0.08;

    if (state == BuddyState.happy) {
      return Container(
        width: mouthWidth,
        height: mouthHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(mouthWidth),
            bottomRight: Radius.circular(mouthWidth),
          ),
        ),
      );
    } else if (state == BuddyState.sympathetic) {
      return Container(
        width: mouthWidth * 0.7,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    } else if (state == BuddyState.thinking) {
      return Container(
        width: mouthWidth * 0.5,
        height: mouthWidth * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: mouthWidth * 0.8,
        height: mouthHeight * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
  }

  Widget _buildAntenna() {
    return Column(
      children: [
        Container(
          width: size * 0.08,
          height: size * 0.08,
          decoration: BoxDecoration(
            color: state == BuddyState.happy
                ? KuwentoColors.buddyHappy
                : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (state == BuddyState.happy
                        ? KuwentoColors.buddyHappy
                        : Colors.white)
                    .withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        Container(
          width: 3,
          height: size * 0.06,
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      width: size * 0.55,
      height: size * 0.5,
      decoration: BoxDecoration(
        color: _primaryColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.15),
          topRight: Radius.circular(size * 0.15),
          bottomLeft: Radius.circular(size * 0.08),
          bottomRight: Radius.circular(size * 0.08),
        ),
      ),
      child: Stack(
        children: [
          // Chest emblem
          Positioned(
            top: size * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size * 0.18,
                height: size * 0.18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: size * 0.1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Belly button
          Positioned(
            bottom: size * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: size * 0.08,
                height: size * 0.08,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArm({required bool isLeft}) {
    return Transform(
      alignment: Alignment.topCenter,
      transform: Matrix4.rotationZ(isLeft ? 0.2 : -0.2),
      child: Column(
        children: [
          // Upper arm
          Container(
            width: size * 0.12,
            height: size * 0.18,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(size * 0.06),
            ),
          ),
          const SizedBox(height: 2),
          // Hand
          Container(
            width: size * 0.1,
            height: size * 0.1,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Speech bubble for buddy messages
class BuddySpeechBubble extends StatelessWidget {
  final String message;
  final BuddyState state;

  const BuddySpeechBubble({
    super.key,
    required this.message,
    required this.state,
  });

  Color get _bubbleColor {
    switch (state) {
      case BuddyState.idle:
        return KuwentoColors.pastelBlue;
      case BuddyState.thinking:
        return KuwentoColors.buddyThinking;
      case BuddyState.happy:
        return KuwentoColors.buddyHappy;
      case BuddyState.encouraging:
        return KuwentoColors.buddyEncouraging;
      case BuddyState.sympathetic:
        return KuwentoColors.buddySympathetic;
      case BuddyState.waving:
        return KuwentoColors.pastelBlue;
      case BuddyState.cheering:
        return KuwentoColors.buddyHappy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            color: isDark ? KuwentoColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _bubbleColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _bubbleColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                  height: 1.4,
                ),
          ),
        ),
        // Triangle pointer
        CustomPaint(
          size: const Size(16, 8),
          painter: _TrianglePainter(
            color: isDark ? KuwentoColors.cardDark : Colors.white,
            borderColor: _bubbleColor.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating buddy widget for bottom right placement
class FloatingBuddy extends StatelessWidget {
  final BuddyState state;
  final String? message;
  final VoidCallback? onTap;

  const FloatingBuddy({
    super.key,
    this.state = BuddyState.idle,
    this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: BuddyCompanion(
        state: state,
        message: message,
        onTap: onTap,
        size: 80,
        showSpeechBubble: message != null,
      ),
    );
  }
}
