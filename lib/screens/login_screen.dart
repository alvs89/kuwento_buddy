import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// Login/Registration screen with unified flow
/// Age-neutral design with social login and guest mode
class LoginScreen extends StatefulWidget {
  final String mode;

  const LoginScreen({super.key, this.mode = 'signin'});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final ToastService _toastService = ToastService();
  bool _isLoading = false;
  bool _floatUp = true;
  static const String _googleLogoAsset = 'assets/icons/google_logo.svg';

  static const Color _deepNavy = Color(0xFF1A2B3C);
  static const Color _deepNavyLighter = Color(0xFF22364A);

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final isSignUpFlow = widget.mode == 'signup';

    try {
      final result = await _authService.authenticateWithGoogle(
        intent: isSignUpFlow ? AuthIntent.signUp : AuthIntent.signIn,
      );

      if (result.user != null && mounted) {
        if (isSignUpFlow && !result.isNewUser) {
          _toastService
              .showInfo('Account already exists. Signed you in instead.');
        } else if (!isSignUpFlow && result.isNewUser) {
          _toastService
              .showInfo('No account found. We created one and signed you in.');
        }

        _toastService.showWelcome(result.user!.firstName);
        context.go('/');
      } else if (result.wasCancelled && mounted) {
        _toastService.showError('Google authentication was cancelled.');
      } else if (mounted) {
        _toastService.showError(
          result.errorMessage ??
              'Google authentication failed. Please try again.',
        );
      }
    } catch (e) {
      _toastService.showErrorWithRetry('signing in');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestContinue() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.continueAsGuest();
      if (mounted) {
        _toastService.showInfo('Welcome! Start reading right away! 📚');
        context.go('/');
      }
    } catch (e) {
      _toastService.showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSignUpFlow = widget.mode == 'signup';

    return Scaffold(
      backgroundColor: _deepNavy,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final isCompact = h < 740;
            final mascotSize = isCompact ? 112.0 : 136.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: isCompact ? 8 : 18),
                      _buildGlassSpeechBubble(),
                      SizedBox(height: isCompact ? 10 : AppSpacing.md),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: _floatUp ? -5 : 5,
                          end: _floatUp ? 5 : -5,
                        ),
                        duration: const Duration(milliseconds: 3200),
                        curve: Curves.easeInOut,
                        onEnd: () {
                          if (!mounted) return;
                          setState(() => _floatUp = !_floatUp);
                        },
                        builder: (context, value, child) {
                          final scale = 1 + (value.abs() / 130);
                          return Transform.translate(
                            offset: Offset(0, value),
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: BuddyCompanion(
                          state: BuddyState.waving,
                          showSpeechBubble: false,
                          size: mascotSize,
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 14),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                'KuwentoBuddy',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: GoogleFonts.poppins(
                                  fontSize: size.width < 360 ? 30 : 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                  shadows: [
                                    Shadow(
                                      color: KuwentoColors.pastelBlue
                                          .withValues(alpha: 0.5),
                                      blurRadius: 18,
                                    ),
                                    const Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                isSignUpFlow
                                    ? 'Create your account and keep stories safe'
                                    : 'Your interactive reading companion',
                                style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w500,
                                        ) ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 14 : 22),
                      _buildPrimaryReadingButton(),
                      const SizedBox(height: AppSpacing.md),
                      _buildGoogleButton(isSignUpFlow),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                'Sign in to sync progress, or start instantly as guest',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.78),
                                          fontWeight: FontWeight.w500,
                                        ) ??
                                    const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading) ...[
                        const SizedBox(height: AppSpacing.md),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: isCompact ? 12 : 18),
                      Material(
                        elevation: 4.0,
                        color: _deepNavyLighter,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: _buildFeatureList(),
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassSpeechBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
            ),
          ),
          child: Text(
            'Kumusta! Ready to read and learn?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryReadingButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF62D88A),
              Color(0xFF46B86C),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF45B66B).withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleGuestContinue,
          icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
          label: const Text(
            'Start Reading',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool isSignUpFlow) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                _googleLogoAsset,
                width: 18,
                height: 18,
                placeholderBuilder: (_) => const Icon(
                  Icons.g_mobiledata,
                  size: 20,
                  color: Color(0xFF4285F4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isSignUpFlow ? 'Sign up with Google' : 'Continue with Google',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF202124),
          side: const BorderSide(color: Color(0xFFDADCE0), width: 1.1),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          elevation: 0,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureListItem(
          icon: Icons.menu_book_rounded,
          title: 'Story Reading',
          subtitle: 'Guided and engaging stories for learners',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFeatureListItem(
          icon: Icons.translate_rounded,
          title: 'Bilingual Learning',
          subtitle: 'Read in English and Filipino',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFeatureListItem(
          icon: Icons.record_voice_over_rounded,
          title: 'Voice Narration',
          subtitle: 'Listen while following each story',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFeatureListItem(
          icon: Icons.psychology_alt_rounded,
          title: 'Comprehension Growth',
          subtitle: 'Strengthen understanding and retention',
        ),
      ],
    );
  }

  Widget _buildFeatureListItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: KuwentoColors.pastelBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.25,
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
