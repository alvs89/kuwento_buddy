import 'package:flutter/material.dart';
import '../theme.dart';

/// BuddyReactionWidget — animated companion with reaction-based expressions.
/// Accepts reaction string ('correct', 'wrong', 'thinking') and changes
/// Buddy's expression, color, and accessories accordingly.
class BuddyReactionWidget extends StatefulWidget {
  final String reaction; // 'correct', 'wrong', 'thinking'
  final double size;

  const BuddyReactionWidget({
    super.key,
    required this.reaction,
    this.size = 160,
  });

  @override
  State<BuddyReactionWidget> createState() => _BuddyReactionWidgetState();
}

class _BuddyReactionWidgetState extends State<BuddyReactionWidget>
    with TickerProviderStateMixin {
  late AnimationController _bodyCtrl;
  late AnimationController _eyeCtrl;
  late Animation<double> _bodyBounce;
  late Animation<double> _eyeBlink;

  @override
  void initState() {
    super.initState();

    // Body subtle bob
    _bodyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bodyBounce = Tween<double>(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeInOut));

    // Eye blink every ~3 seconds
    _eyeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _eyeBlink = Tween<double>(begin: 1.0, end: 0.05).animate(_eyeCtrl);
    _startBlinkLoop();
  }

  void _startBlinkLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) break;
      await _eyeCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) break;
      _eyeCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _eyeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bodyBounce,
        _eyeBlink,
      ]),
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _bodyBounce.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size * 1.25,
            child: CustomPaint(
              painter: _BuddyReactionPainter(
                reaction: widget.reaction,
                eyeScaleY: _eyeBlink.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BuddyReactionPainter extends CustomPainter {
  final String reaction; // 'correct', 'wrong', 'thinking'
  final double eyeScaleY;

  const _BuddyReactionPainter({
    required this.reaction,
    required this.eyeScaleY,
  });

  Color get _primaryColor {
    switch (reaction) {
      case 'correct':
        return KuwentoColors.buddyHappy;
      case 'wrong':
        return KuwentoColors.buddySympathetic;
      case 'thinking':
        return KuwentoColors.buddyThinking;
      default:
        return KuwentoColors.pastelBlue;
    }
  }

  Color get _accentColor {
    switch (reaction) {
      case 'correct':
        return Colors.green;
      case 'wrong':
        return Colors.red;
      case 'thinking':
        return Colors.orange;
      default:
        return KuwentoColors.softCoral;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final primaryColor = _primaryColor;
    final accentColor = _accentColor;
    final cream = KuwentoColors.cream;

    // ── BODY ──────────────────────────────────────────────────────
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor.withAlpha(200), primaryColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - 34, 70, 68, 90));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 115), width: 68, height: 90),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // ── NECK ──────────────────────────────────────────────────────
    final neckPaint = Paint()..color = primaryColor.withAlpha(180);
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
        colors: [primaryColor, primaryColor.withAlpha(220)],
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
    _drawEyes(canvas, cx, primaryColor);

    // ── EXPRESSION (mouth) ────────────────────────────────────────
    _drawExpression(canvas, cx);

    // ── ANTENNA/STREAK ───────────────────────────────────────────
    final antPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 19), Offset(cx, 10), antPaint);
    canvas.drawCircle(Offset(cx, 8), 5, Paint()..color = accentColor);

    // ── ARMS ──────────────────────────────────────────────────────
    _drawArms(canvas, cx, primaryColor, accentColor);

    // ── LEGS ──────────────────────────────────────────────────────
    _drawLegs(canvas, cx, primaryColor);

    // ── CHEST BADGE ───────────────────────────────────────────────
    _drawChestBadge(canvas, cx);
  }

  void _drawEyes(Canvas canvas, double cx, Color primaryColor) {
    final eyePaint = Paint()..color = Colors.black87;
    for (final ex in [cx - 14.0, cx + 14.0]) {
      canvas.save();
      canvas.translate(ex, 46);
      canvas.scale(1.0, eyeScaleY);

      if (reaction == 'correct') {
        // Happy eyes (closed smile)
        final smilePath = Path();
        smilePath.moveTo(-5, 0);
        smilePath.quadraticBezierTo(0, 5, 5, 0);
        canvas.drawPath(
            smilePath,
            Paint()
              ..color = primaryColor
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round);
      } else if (reaction == 'wrong') {
        // Sad eyes (X)
        canvas.drawLine(
          const Offset(-4, -4),
          const Offset(4, 4),
          Paint()
            ..color = primaryColor
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          const Offset(4, -4),
          const Offset(-4, 4),
          Paint()
            ..color = primaryColor
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      } else {
        // Thinking eyes (circles)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
            const Radius.circular(7),
          ),
          eyePaint,
        );
        canvas.drawCircle(
          const Offset(3, -3),
          3,
          Paint()..color = Colors.white.withAlpha(180),
        );
      }
      canvas.restore();
    }
  }

  void _drawExpression(Canvas canvas, double cx) {
    if (reaction == 'correct') {
      // Happy smile
      final smilePaint = Paint()
        ..color = _primaryColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final smilePath = Path();
      smilePath.moveTo(cx - 14, 64);
      smilePath.quadraticBezierTo(cx, 72, cx + 14, 64);
      canvas.drawPath(smilePath, smilePaint);
    } else if (reaction == 'wrong') {
      // Sad mouth line
      final sadPaint = Paint()
        ..color = _primaryColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final sadPath = Path();
      sadPath.moveTo(cx - 14, 72);
      sadPath.quadraticBezierTo(cx, 64, cx + 14, 72);
      canvas.drawPath(sadPath, sadPaint);
    } else {
      // Thinking - circle mouth
      canvas.drawCircle(
        Offset(cx, 68),
        4,
        Paint()..color = _primaryColor,
      );
    }
  }

  void _drawArms(
      Canvas canvas, double cx, Color primaryColor, Color accentColor) {
    // Left arm
    final leftArmPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 34, 90), Offset(cx - 52, 118), leftArmPaint);
    canvas.drawCircle(
        Offset(cx - 54, 122), 9, Paint()..color = primaryColor.withAlpha(200));

    // Right arm
    final rightArmPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 34, 90), Offset(cx + 52, 118), rightArmPaint);
    canvas.drawCircle(Offset(cx + 54, 122), 9, Paint()..color = accentColor);
  }

  void _drawLegs(Canvas canvas, double cx, Color primaryColor) {
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
        Paint()..color = primaryColor.withAlpha(200),
      );
    }
  }

  void _drawChestBadge(Canvas canvas, double cx) {
    final badgePaint = Paint()..color = Colors.white.withAlpha(60);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 108), width: 36, height: 22),
        const Radius.circular(8),
      ),
      badgePaint,
    );

    final emoji = reaction == 'correct'
        ? '✓'
        : reaction == 'wrong'
            ? '✗'
            : '💭';
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - 8, 100));
  }

  @override
  bool shouldRepaint(_BuddyReactionPainter old) =>
      old.reaction != reaction || old.eyeScaleY != eyeScaleY;
}
