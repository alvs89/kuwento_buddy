import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/services/auth_service.dart' as kuwentobuddy;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowPulse;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  static const String _loginRoute = '/login';

  List<Widget> _buildFloatingParticles(bool isDark) {
    final particleColor = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : KuwentoColors.pastelBlueDark.withValues(alpha: 0.1);

    final positions = <Map<String, double>>[
      {'top': 130, 'left': 52, 'size': 7},
      {'top': 200, 'right': 58, 'size': 10},
      {'top': 320, 'left': 84, 'size': 5},
      {'top': 430, 'right': 88, 'size': 8},
      {'bottom': 220, 'left': 56, 'size': 9},
      {'bottom': 146, 'right': 74, 'size': 6},
    ];

    return positions
        .map(
          (entry) => Positioned(
            top: entry['top'],
            left: entry['left'],
            right: entry['right'],
            bottom: entry['bottom'],
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.15, 0.95, curve: Curves.easeInOut),
              ),
              child: Container(
                width: entry['size'],
                height: entry['size'],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: particleColor,
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.0, end: 14.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateNext());
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 4000));
    if (!mounted) return;

    // Use router's redirect logic or explicitly navigate to correct initial state
    final authService =
        context.read<kuwentobuddy.AuthService>(); // Need to import this
    if (authService.isAuthenticated) {
      context.go('/profile-selection');
    } else if (authService.isGuest) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? [
            const Color(0xFF112034),
            KuwentoColors.surfaceDark,
            KuwentoColors.pastelBlueDark,
          ]
        : [
            const Color(0xFFEAF6FD),
            KuwentoColors.skyBlueLight,
            KuwentoColors.pastelBlue,
          ];

    final glowColor = isDark
        ? KuwentoColors.pastelBlueLight.withValues(alpha: 0.45)
        : KuwentoColors.pastelBlue.withValues(alpha: 0.36);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
                stops: const [0.08, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -70,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isDark
                              ? KuwentoColors.pastelBlueLight
                              : KuwentoColors.skyBlue)
                          .withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -90,
            child: IgnorePointer(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isDark
                              ? KuwentoColors.softCoral
                              : KuwentoColors.pastelBlueLight)
                          .withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _StoryPatternPainter(isDark: isDark),
              ),
            ),
          ),
          ..._buildFloatingParticles(isDark),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 44,
                            vertical: 40,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.white.withValues(alpha: 0.03),
                                    ]
                                  : [
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.92),
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: glowColor,
                                blurRadius: 30 + _glowPulse.value,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.35 : 0.12),
                                blurRadius: 22,
                                offset: const Offset(0, 14),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: isDark ? 0.12 : 0.36),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'KB',
                            style: theme.textTheme.displaySmall?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : KuwentoColors.textPrimary,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.w700,
                                ) ??
                                TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : KuwentoColors.textPrimary,
                                  letterSpacing: 6,
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Text(
                      'Kuwento Buddy',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPatternPainter extends CustomPainter {
  const _StoryPatternPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : KuwentoColors.pastelBlueDark.withValues(alpha: 0.1);

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : KuwentoColors.textSecondary.withValues(alpha: 0.08);

    // Open-book inspired arc near bottom left.
    final bookArc = Path()
      ..moveTo(size.width * 0.14, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.73,
        size.width * 0.44,
        size.height * 0.8,
      );
    canvas.drawPath(bookArc, linePaint);

    final bookArc2 = Path()
      ..moveTo(size.width * 0.56, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.73,
        size.width * 0.86,
        size.height * 0.8,
      );
    canvas.drawPath(bookArc2, linePaint);

    // Minimal page-lines accent in upper-right quadrant.
    final pageLeft = size.width * 0.68;
    final pageTop = size.height * 0.2;
    final pageWidth = size.width * 0.17;
    final lineGap = size.height * 0.03;
    for (var i = 0; i < 4; i++) {
      final y = pageTop + (i * lineGap);
      canvas.drawLine(
        Offset(pageLeft, y),
        Offset(pageLeft + pageWidth, y),
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StoryPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
