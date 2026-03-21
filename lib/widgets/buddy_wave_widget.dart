import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// BuddyWaveWidget — animated companion robot with waving arm.
/// Body parts are individually animated using multiple AnimationControllers.
class BuddyWaveWidget extends StatefulWidget {
  final bool isLoading;
  final double size;

  const BuddyWaveWidget({
    super.key,
    this.isLoading = false,
    this.size = 160,
  });

  @override
  State<BuddyWaveWidget> createState() => _BuddyWaveWidgetState();
}

class _BuddyWaveWidgetState extends State<BuddyWaveWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _bodyCtrl;
  late AnimationController _eyeCtrl;
  late AnimationController _loadCtrl;

  late Animation<double> _waveAngle;
  late Animation<double> _bodyBounce;
  late Animation<double> _eyeBlink;
  late Animation<double> _loadShake;

  @override
  void initState() {
    super.initState();

    // Wave arm: oscillates back and forth
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _waveAngle = Tween<double>(
      begin: -0.3,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));

    // Body subtle bounce
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

    // Loading shake
    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadShake = Tween<double>(
      begin: -4.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _loadCtrl, curve: Curves.elasticIn));
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
  void didUpdateWidget(BuddyWaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _loadCtrl.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _loadCtrl.stop();
      _loadCtrl.reset();
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _bodyCtrl.dispose();
    _eyeCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _waveAngle,
        _bodyBounce,
        _eyeBlink,
        _loadShake,
      ]),
      builder: (_, __) {
        return Column(
          children: [
            Transform.translate(
              offset: Offset(
                widget.isLoading ? _loadShake.value : 0,
                _bodyBounce.value,
              ),
              child: SizedBox(
                width: widget.size,
                height: widget.size * 1.25,
                child: CustomPaint(
                  painter: _BuddyPainter(
                    waveAngle: _waveAngle.value,
                    eyeScaleY: _eyeBlink.value,
                    isLoading: widget.isLoading,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: KuwentoColors.skyBlueLight.withAlpha(220),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                widget.isLoading
                    ? 'Sandali lang... 🤔'
                    : 'Kamusta! Tara, magbasa tayo! 👋',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KuwentoColors.pastelBlueDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BuddyPainter extends CustomPainter {
  final double waveAngle;
  final double eyeScaleY;
  final bool isLoading;

  const _BuddyPainter({
    required this.waveAngle,
    required this.eyeScaleY,
    required this.isLoading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final teal = KuwentoColors.pastelBlue;
    final tealLight = KuwentoColors.pastelBlueLight;
    final cream = KuwentoColors.cream;
    final coral = KuwentoColors.softCoral;

    // ── BODY ──────────────────────────────────────────────────────
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [tealLight, teal],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - 34, 70, 68, 90));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 115), width: 68, height: 90),
      const Radius.circular(22),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // ── NECK ──────────────────────────────────────────────────────
    final neckPaint = Paint()..color = tealLight;
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
        colors: [const Color(0xFF1EC8CC), tealLight],
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
    final eyePaint = Paint()..color = teal;
    for (final ex in [cx - 14.0, cx + 14.0]) {
      canvas.save();
      canvas.translate(ex, 46);
      canvas.scale(1.0, eyeScaleY);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
          const Radius.circular(7),
        ),
        eyePaint,
      );
      // Eye shine
      canvas.drawCircle(
        const Offset(3, -3),
        3,
        Paint()..color = Colors.white.withAlpha(180),
      );
      canvas.restore();
    }

    // ── SMILE ────────────────────────────────────────────────────
    final smilePaint = Paint()
      ..color = isLoading ? coral : teal
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.moveTo(cx - 14, 64);
    smilePath.quadraticBezierTo(cx, isLoading ? 68 : 72, cx + 14, 64);
    canvas.drawPath(smilePath, smilePaint);

    // ── ANTENNA ───────────────────────────────────────────────────
    final antPaint = Paint()
      ..color = coral
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, 19), Offset(cx, 10), antPaint);
    canvas.drawCircle(Offset(cx, 8), 5, Paint()..color = coral);

    // ── LEFT ARM (static) ────────────────────────────────────────
    final leftArmPaint = Paint()
      ..color = teal
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 34, 90), Offset(cx - 52, 118), leftArmPaint);
    // Left hand
    canvas.drawCircle(Offset(cx - 54, 122), 9, Paint()..color = tealLight);

    // ── RIGHT ARM (waving) ───────────────────────────────────────
    canvas.save();
    canvas.translate(cx + 34, 90);
    canvas.rotate(waveAngle);
    final rightArmPaint = Paint()
      ..color = teal
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, const Offset(20, -22), rightArmPaint);
    canvas.drawCircle(const Offset(24, -28), 9, Paint()..color = coral);
    canvas.restore();

    // ── LEGS ─────────────────────────────────────────────────────
    final legPaint = Paint()
      ..color = teal
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
        Paint()..color = tealLight,
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
  }

  @override
  bool shouldRepaint(_BuddyPainter old) =>
      old.waveAngle != waveAngle ||
      old.eyeScaleY != eyeScaleY ||
      old.isLoading != isLoading;
}
