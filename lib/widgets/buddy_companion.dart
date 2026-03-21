import 'dart:async';
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
  final String? tapMessage;
  final VoidCallback? onTap;
  final double size;
  final bool showSpeechBubble;
  final bool enableTapSpeechBubble;
  final Duration speechBubbleAutoHideDuration;
  final String? speechTitle;
  final bool disableHighlightEffects;
  final Color? bodyColor;

  const BuddyCompanion({
    super.key,
    this.state = BuddyState.idle,
    this.message,
    this.tapMessage,
    this.onTap,
    this.size = 120,
    this.showSpeechBubble = true,
    this.enableTapSpeechBubble = false,
    this.speechBubbleAutoHideDuration = const Duration(seconds: 4),
    this.speechTitle,
    this.disableHighlightEffects = false,
    this.bodyColor,
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
  bool _isSpeechBubbleVisible = false;
  Timer? _speechBubbleTimer;
  OverlayEntry? _tooltipOverlay;

  String? get _activeSpeechText => widget.tapMessage ?? widget.message;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void _showTooltip() {
    _tooltipOverlay?.remove();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero);

    _tooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        right: 16,
        top: (position?.dy ?? 0) - 80,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.95)
                  : Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tap to chat with Buddy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_tooltipOverlay!);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _tooltipOverlay?.remove();
      _tooltipOverlay = null;
    });
  }

  @override
  void didUpdateWidget(BuddyCompanion oldWidget) {
    _tooltipOverlay?.remove();
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _handleStateChange();
    }

    if (!widget.enableTapSpeechBubble) {
      _hideSpeechBubble(cancelTimer: true);
      return;
    }

    if (_activeSpeechText == null) {
      _hideSpeechBubble(cancelTimer: true);
    }
  }

  void _handleStateChange() {
    if (MediaQuery.of(context).disableAnimations) return;

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
    _tooltipOverlay?.remove();
    _speechBubbleTimer?.cancel();
    _bounceController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _headTiltController.dispose();
    super.dispose();
  }

  void _toggleSpeechBubble() {
    if (!widget.enableTapSpeechBubble || _activeSpeechText == null) {
      return;
    }

    setState(() {
      _isSpeechBubbleVisible = !_isSpeechBubbleVisible;
    });

    if (_isSpeechBubbleVisible) {
      _speechBubbleTimer?.cancel();
      _speechBubbleTimer =
          Timer(widget.speechBubbleAutoHideDuration, _hideSpeechBubble);
    } else {
      _speechBubbleTimer?.cancel();
    }
  }

  void _hideSpeechBubble({bool cancelTimer = false}) {
    if (!mounted) {
      return;
    }

    if (cancelTimer) {
      _speechBubbleTimer?.cancel();
    }

    if (_isSpeechBubbleVisible) {
      setState(() {
        _isSpeechBubbleVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSpeechText = _activeSpeechText;
    final shouldShowSpeechBubble = widget.showSpeechBubble &&
        activeSpeechText != null &&
        (!widget.enableTapSpeechBubble || _isSpeechBubbleVisible);
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final orientation = media.orientation;
    final isLandscape = orientation == Orientation.landscape;
    final compactScreen = screenWidth < 360;
    final tabletScreen = screenWidth >= 600;
    final wideScreen = screenWidth >= 700;
    final dynamicSize =
        widget.size * (tabletScreen ? 1.15 : 1.0) * (isLandscape ? 0.9 : 1.0);
    final bubbleBottomOffset = (dynamicSize * 1.3) +
        (compactScreen ? 28.0 : 34.0) +
        (isLandscape ? 10.0 : 0.0);
    final bubbleMaxWidth = math.min(
      wideScreen
          ? 360.0
          : screenWidth * (isLandscape ? 0.40 : (compactScreen ? 0.74 : 0.58)),
      math.max(
          164.0, screenWidth - dynamicSize - (compactScreen ? 48.0 : 76.0)),
    );

    final reducedMotion = MediaQuery.of(context).disableAnimations;

    if (reducedMotion) {
      _bounceController.stop();
      _pulseController.stop();
      _waveController.stop();
      _headTiltController.stop();
    }

    return Semantics(
      button: true,
      enabled: true,
      label: 'Kuwento Buddy (${widget.state.name})',
      hint: activeSpeechText != null
          ? shouldShowSpeechBubble
              ? 'Tap to hide the buddy message'
              : 'Tap to show the buddy message'
          : 'Assistant companion',
      child: Material(
        color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        hoverColor:
            widget.disableHighlightEffects ? Colors.transparent : null,
        focusColor:
            widget.disableHighlightEffects ? Colors.transparent : null,
        highlightColor:
            widget.disableHighlightEffects ? Colors.transparent : null,
        splashColor:
            widget.disableHighlightEffects ? Colors.transparent : null,
        overlayColor: widget.disableHighlightEffects
            ? WidgetStateProperty.all(Colors.transparent)
            : null,
          onTap: () {
            HapticFeedback.selectionClick();
            _toggleSpeechBubble();
            widget.onTap?.call();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showTooltip();
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.max(dynamicSize, 72.0),
              minHeight: math.max(dynamicSize, 72.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomRight,
              children: [
                // Buddy fixed at bottom-right
                RepaintBoundary(
                  child: AnimatedBuilder(
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
                      bodyColor: widget.bodyColor,
                    ),
                  ),
                ),
                // Speech bubble positioned above Buddy, with animated entrance
                Positioned(
                  right: compactScreen ? 2 : 0,
                  bottom: bubbleBottomOffset,
                  child: IgnorePointer(
                    ignoring: !shouldShowSpeechBubble,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      reverseDuration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.08, 0.12),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        );
                      },
                      child: shouldShowSpeechBubble
                          ? RepaintBoundary(
                              key: ValueKey<String>(
                                '${widget.state.name}:${_activeSpeechText ?? ''}',
                              ),
                      child: BuddySpeechBubble(
                        message: _activeSpeechText ?? '',
                        state: widget.state,
                        alignLeft: false,
                        arrowOnLowerRight: true,
                        maxWidth: bubbleMaxWidth,
                        titleOverride: widget.speechTitle,
                      ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The actual buddy character with CustomPainter-drawn body parts
class _BuddyCharacter extends StatelessWidget {
  final double size;
  final BuddyState state;
  final Animation<double> waveAnimation;
  final Animation<double> headTiltAnimation;
  final Color? bodyColor;

  const _BuddyCharacter({
    required this.size,
    required this.state,
    required this.waveAnimation,
    required this.headTiltAnimation,
    this.bodyColor,
  });

  Color get _primaryColor => bodyColor ?? _stateColor;

  Color get _stateColor {
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
          // Custom painted character with wave and head tilt animations
          AnimatedBuilder(
            animation: Listenable.merge([waveAnimation, headTiltAnimation]),
            builder: (context, _) {
              final waveAngle =
                  state == BuddyState.waving ? waveAnimation.value : 0.0;
              final headTilt = headTiltAnimation.value;

              return Transform.rotate(
                angle: headTilt,
                child: CustomPaint(
                  painter: _BuddyCharacterPainter(
                    primaryColor: _primaryColor,
                    state: state,
                    waveAngle: waveAngle,
                  ),
                  size: Size(size, size * 1.3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BuddyCharacterPainter extends CustomPainter {
  final Color primaryColor;
  final BuddyState state;
  final double waveAngle;

  const _BuddyCharacterPainter({
    required this.primaryColor,
    required this.state,
    required this.waveAngle,
  });

  Color get _lightColor => primaryColor.withAlpha(200);

  @override
  void paint(Canvas canvas, Size size) {
    const baseWidth = 120.0;
    final scale = size.width / baseWidth;
    canvas.save();
    canvas.scale(scale);

    final cx = baseWidth / 2;
    final cream = KuwentoColors.cream;
    final accentColor = KuwentoColors.softCoral;

    // ── BODY ──────────────────────────────────────────────────────
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [_lightColor, primaryColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - 34, 70, 68, 90));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 115), width: 68, height: 90),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // ── NECK ──────────────────────────────────────────────────────
    final neckPaint = Paint()..color = _lightColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 72), width: 20, height: 12),
        const Radius.circular(6),
      ),
      neckPaint,
    );

    // ── HEAD ──────────────────────────────────────────────────────
    final headPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, _lightColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(cx - 40, 20, 80, 65));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 52), width: 80, height: 65),
        const Radius.circular(28),
      ),
      headPaint,
    );

    // ── FACE PLATE ────────────────────────────────────────────────
    final facePaint = Paint()..color = cream.withAlpha(230);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 52), width: 62, height: 50),
        const Radius.circular(20),
      ),
      facePaint,
    );

    // ── EYES ──────────────────────────────────────────────────────
    final eyePaint = Paint()..color = primaryColor;
    for (final ex in [cx - 14.0, cx + 14.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(ex, 46), width: 14, height: 14),
          const Radius.circular(7),
        ),
        eyePaint,
      );
      // Eye shine
      canvas.drawCircle(
        Offset(ex + 3, 43),
        3,
        Paint()..color = Colors.white.withAlpha(180),
      );
    }

    // ── SMILE ────────────────────────────────────────────────────
    final smilePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cx - 14, 64);
    smilePath.quadraticBezierTo(cx, 72, cx + 14, 64);
    canvas.drawPath(smilePath, smilePaint);

    // ── ANTENNA ───────────────────────────────────────────────────
    final antPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 19), Offset(cx, 10), antPaint);
    canvas.drawCircle(Offset(cx, 8), 5, Paint()..color = accentColor);

    // ── LEFT ARM (static) ────────────────────────────────────────
    final leftArmPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 34, 90), Offset(cx - 52, 118), leftArmPaint);
    canvas.drawCircle(Offset(cx - 54, 122), 9, Paint()..color = _lightColor);

    // ── RIGHT ARM (waving) ───────────────────────────────────────
    canvas.save();
    canvas.translate(cx + 34, 90);
    canvas.rotate(waveAngle);
    final rightArmPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, const Offset(20, -22), rightArmPaint);
    canvas.drawCircle(const Offset(24, -28), 9, Paint()..color = accentColor);
    canvas.restore();

    // ── LEGS ──────────────────────────────────────────────────────
    final legPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 16, 158), Offset(cx - 18, 185), legPaint);
    canvas.drawLine(Offset(cx + 16, 158), Offset(cx + 18, 185), legPaint);

    // Feet
    for (final fx in [cx - 20.0, cx + 20.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(fx, 190), width: 20, height: 10),
          const Radius.circular(5),
        ),
        Paint()..color = _lightColor,
      );
    }

    // ── CHEST BADGE ───────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 108), width: 36, height: 22),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.white.withAlpha(60),
    );
    final textPainter = TextPainter(
      text: const TextSpan(text: '📚', style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - 8, 100));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BuddyCharacterPainter old) =>
      old.primaryColor != primaryColor ||
      old.state != state ||
      old.waveAngle != waveAngle;
}

/// Speech bubble for buddy messages
class BuddySpeechBubble extends StatelessWidget {
  final String message;
  final BuddyState state;
  final bool alignLeft;
  final bool arrowOnLowerRight;
  final double? maxWidth;
  final String? titleOverride;

  const BuddySpeechBubble({
    super.key,
    required this.message,
    required this.state,
    this.alignLeft = false,
    this.arrowOnLowerRight = false,
    this.maxWidth,
    this.titleOverride,
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

  String get _stateLabel {
    switch (state) {
      case BuddyState.idle:
        return 'Buddy Tip';
      case BuddyState.thinking:
        return 'Thinking Together';
      case BuddyState.happy:
        return 'Nice Work';
      case BuddyState.encouraging:
        return 'Keep Going';
      case BuddyState.sympathetic:
        return 'Take Your Time';
      case BuddyState.waving:
        return 'Hello';
      case BuddyState.cheering:
        return 'Celebrate';
    }
  }

  IconData get _stateIcon {
    switch (state) {
      case BuddyState.idle:
        return Icons.auto_awesome_rounded;
      case BuddyState.thinking:
        return Icons.lightbulb_rounded;
      case BuddyState.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case BuddyState.encouraging:
        return Icons.favorite_rounded;
      case BuddyState.sympathetic:
        return Icons.volunteer_activism_rounded;
      case BuddyState.waving:
        return Icons.waving_hand_rounded;
      case BuddyState.cheering:
        return Icons.celebration_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final compactScreen = media.size.shortestSide < 360;
    final wideScreen = media.size.width >= 700;
    final bubbleMaxWidth = maxWidth ??
        math.min(320.0, media.size.width * (compactScreen ? 0.76 : 0.64));
    final bubbleMinWidth =
        math.min(bubbleMaxWidth, compactScreen ? 148.0 : 176.0);
    final surfaceColor = isDark
        ? Color.alphaBlend(
            _bubbleColor.withValues(alpha: 0.14),
            KuwentoColors.cardDark,
          )
        : Color.alphaBlend(
            _bubbleColor.withValues(alpha: 0.1),
            Colors.white,
          );
    final highlightColor = isDark
        ? _bubbleColor.withValues(alpha: 0.08)
        : _bubbleColor.withValues(alpha: 0.14);
    final borderColor = _bubbleColor.withValues(alpha: isDark ? 0.46 : 0.3);
    final titleStyle = theme.textTheme.labelLarge?.copyWith(
      color: isDark ? Colors.white : KuwentoColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    final messageStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isDark ? Colors.white : KuwentoColors.textPrimary,
      fontWeight: FontWeight.w500,
      fontSize: compactScreen ? 13.5 : (wideScreen ? 15.0 : 14.0),
      height: 1.45,
    );

    final titleText = titleOverride ?? _stateLabel;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bubble
        Semantics(
          liveRegion: true,
          label: 'Buddy says: $message',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            padding: EdgeInsets.fromLTRB(
              compactScreen ? 14 : 16,
              compactScreen ? 12 : 14,
              compactScreen ? 14 : 16,
              compactScreen ? 12 : 14,
            ),
            constraints: BoxConstraints(
              minWidth: bubbleMinWidth,
              maxWidth: bubbleMaxWidth,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  surfaceColor,
                  Color.alphaBlend(highlightColor, surfaceColor),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(alignLeft ? 12 : 22),
                bottomRight: Radius.circular(arrowOnLowerRight ? 12 : 22),
              ),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _bubbleColor.withValues(alpha: isDark ? 0.18 : 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: alignLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Container(
                        width: compactScreen ? 28 : 30,
                      height: compactScreen ? 28 : 30,
                      decoration: BoxDecoration(
                        color: _bubbleColor.withValues(
                          alpha: isDark ? 0.24 : 0.14,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _stateIcon,
                        size: compactScreen ? 16 : 18,
                        color: _bubbleColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.left,
                  style: messageStyle,
                ),
              ],
            ),
          ),
        ),
        if (arrowOnLowerRight)
          Positioned(
            right: compactScreen ? 18 : 24,
            bottom: compactScreen ? -32 : -36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BubbleDot(
                  size: compactScreen ? 12 : 14,
                  color: surfaceColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 2),
                Transform.translate(
                  offset: const Offset(4, 0),
                  child: BubbleDot(
                    size: compactScreen ? 9 : 10,
                    color: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(height: 2),
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: BubbleDot(
                    size: compactScreen ? 6 : 7,
                    color: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
          ),
        if (!arrowOnLowerRight && alignLeft)
          Positioned(
            left: compactScreen ? 18 : 24,
            bottom: compactScreen ? -32 : -36,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BubbleDot(
                  size: compactScreen ? 12 : 14,
                  color: surfaceColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 2),
                Transform.translate(
                  offset: const Offset(-4, 0),
                  child: BubbleDot(
                    size: compactScreen ? 9 : 10,
                    color: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(height: 2),
                Transform.translate(
                  offset: const Offset(-8, 0),
                  child: BubbleDot(
                    size: compactScreen ? 6 : 7,
                    color: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// MOVED OUTSIDE: Ellipsis bubble dot widget
class BubbleDot extends StatelessWidget {
  final double size;
  final Color color;
  final Color borderColor;

  const BubbleDot({
    super.key,
    required this.size,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
    );
  }
}

/* Removed unused _TrianglePainter */

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
