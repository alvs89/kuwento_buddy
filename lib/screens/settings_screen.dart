import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/tts_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';

/// Settings screen for user preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ToastService _toastService = ToastService();
  bool _previewInEnglish = false;
  final Set<int> _expandedFaqItems = <int>{};
  double _voiceSpeed = 1.0;
  bool _speedInitialized = false;
  bool _savingVoiceSpeed = false;

  static const String _filipinoSample =
      'Mabuti na mayroon tayong Reading Companion.';
  static const String _englishSample =
      "It's good that we have a Reading Companion.";

  static const List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I start reading a story?',
      'answer':
          'Go to the Library tab, choose a story card, then tap it to open the reading session. Use the next button to move through each part.',
    },
    {
      'question': 'Can I read in English and Filipino?',
      'answer':
          'Yes. During a story session, tap the translate icon in the header to switch between English and Filipino.',
    },
    {
      'question': 'How do I use voice narration?',
      'answer':
          'Open any story and press the play button in the bottom controls. Press pause to stop temporarily and play again to continue narration.',
    },
    {
      'question': 'How does KuwentoBuddy improve comprehension?',
      'answer':
          'The app adds checkpoints and short questions while reading so learners think about the story, not just finish it quickly.',
    },
    {
      'question': 'Will my progress be saved?',
      'answer':
          'Yes. If you sign in, your stars, completed stories, and favorites can be synced. Guest mode works instantly for quick reading.',
    },
  ];

  String get _activePreviewText =>
      _previewInEnglish ? _englishSample : _filipinoSample;

  String get _activePreviewLocale => _previewInEnglish ? 'en-US' : 'fil-PH';

  Future<void> _playNarratorPreview(TTSService ttsService) async {
    await ttsService.speak(
      _activePreviewText,
      language: _activePreviewLocale,
    );
  }

  void _ensureSpeedInitialized(AuthService authService, TTSService ttsService) {
    if (_speedInitialized) return;

    _voiceSpeed = authService.currentUser?.preferences.voiceSpeed ??
        ttsService.voiceSpeedMultiplier;
    _voiceSpeed = _voiceSpeed.clamp(0.5, 2.0);
    _speedInitialized = true;
  }

  Future<void> _saveVoiceSpeed(AuthService authService, double value) async {
    final user = authService.currentUser;
    if (user == null) return;

    setState(() {
      _savingVoiceSpeed = true;
    });

    final updatedPreferences = user.preferences.copyWith(
      voiceSpeed: value,
    );
    final updatedUser = user.copyWith(
      preferences: updatedPreferences,
    );

    await authService.updateUser(updatedUser);

    if (!mounted) return;
    setState(() {
      _savingVoiceSpeed = false;
    });
    _toastService.showSuccess('Voice speed saved');
  }

  Future<void> _confirmAndSignOut(AuthService authService) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final compact = size.width < 360;
        final maxDialogWidth = compact ? size.width * 0.94 : 420.0;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxDialogWidth),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? KuwentoColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: KuwentoColors.pastelBlue.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: KuwentoColors.softCoral.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: KuwentoColors.softCoral,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign out?',
                    style: Theme.of(dialogContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : KuwentoColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Do you want to sign out of your account? You can sign back in anytime.',
                    style:
                        Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : KuwentoColors.textSecondary,
                              height: 1.4,
                            ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            style: OutlinedButton.styleFrom(
                              fixedSize: const Size.fromHeight(48),
                              side: BorderSide(
                                color: KuwentoColors.pastelBlue
                                    .withValues(alpha: 0.55),
                                width: 1.4,
                              ),
                              padding: EdgeInsets.zero,
                              foregroundColor: isDark
                                  ? Colors.white70
                                  : KuwentoColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            style: FilledButton.styleFrom(
                              fixedSize: const Size.fromHeight(48),
                              backgroundColor: KuwentoColors.softCoral,
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: KuwentoColors.softCoral,
                                width: 1.4,
                              ),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;

    await authService.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final authService = context.watch<AuthService>();
    final ttsService = context.watch<TTSService>();
    _ensureSpeedInitialized(authService, ttsService);
    final user = authService.currentUser;
    final photoUrl = user?.photoUrl?.trim();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : KuwentoColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : KuwentoColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? KuwentoColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color:
                              KuwentoColors.pastelBlue.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: KuwentoColors.pastelBlue,
                                    size: 30,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: KuwentoColors.pastelBlue,
                                size: 30,
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Guest Reader',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : KuwentoColors.textPrimary,
                                  ),
                            ),
                            Text(
                              user?.isGuest == true
                                  ? 'Reading as Guest'
                                  : user?.email ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : KuwentoColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (user?.isGuest == true)
                        TextButton(
                          onPressed: () => context.push('/login?mode=signin'),
                          child: Text(
                            'Sign In',
                            style: TextStyle(color: KuwentoColors.pastelBlue),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Stats section
                if (user != null) ...[
                  Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : KuwentoColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildStatCard(
                        context,
                        Icons.star,
                        '${user.totalStars}',
                        'Stars',
                        KuwentoColors.buddyThinking,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatCard(
                        context,
                        Icons.auto_stories,
                        '${user.storiesCompleted}',
                        'Stories',
                        KuwentoColors.buddyHappy,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatCard(
                        context,
                        Icons.favorite,
                        '${user.favoriteStoryIds.length}',
                        'Favorites',
                        KuwentoColors.softCoral,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Voice settings
                Text(
                  'Voice Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : KuwentoColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? KuwentoColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : KuwentoColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : KuwentoColors.creamDark,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: KuwentoColors.pastelBlue
                                        .withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.record_voice_over_rounded,
                                    color: KuwentoColors.pastelBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Narrator',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : KuwentoColors.textPrimary,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Bilingual preview: Filipino and English',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white70
                                                  : KuwentoColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Sample Script',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : KuwentoColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.16)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : KuwentoColors.creamDark,
                                ),
                              ),
                              child: Text(
                                _activePreviewText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : KuwentoColors.textPrimary,
                                      height: 1.5,
                                    ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _playNarratorPreview(ttsService),
                                    icon: Icon(
                                      ttsService.isSpeaking
                                          ? Icons.pause_circle
                                          : Icons.play_arrow_rounded,
                                    ),
                                    label: Text(
                                      ttsService.isSpeaking
                                          ? 'Playing...'
                                          : 'Play',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KuwentoColors.pastelBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _previewInEnglish = !_previewInEnglish;
                                      });
                                    },
                                    icon: const Icon(Icons.translate_rounded),
                                    label: Text(
                                      _previewInEnglish
                                          ? 'Original'
                                          : 'Translate',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: KuwentoColors.pastelBlue,
                                      side: BorderSide(
                                        color: KuwentoColors.pastelBlue
                                            .withValues(alpha: 0.7),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : KuwentoColors.creamDark,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.speed_rounded,
                                        color: KuwentoColors.pastelBlue,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        'Narration Speed',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white
                                                  : KuwentoColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: KuwentoColors.pastelBlue
                                              .withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                        ),
                                        child: Text(
                                          '${_voiceSpeed.toStringAsFixed(2)}x',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: KuwentoColors.pastelBlue,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor:
                                          KuwentoColors.pastelBlue,
                                      inactiveTrackColor: isDark
                                          ? Colors.white24
                                          : KuwentoColors.creamDark,
                                      thumbColor: KuwentoColors.pastelBlue,
                                      overlayColor: KuwentoColors.pastelBlue
                                          .withValues(alpha: 0.14),
                                    ),
                                    child: Slider(
                                      min: 0.5,
                                      max: 2.0,
                                      divisions: 15,
                                      value: _voiceSpeed,
                                      onChanged: (value) {
                                        setState(() {
                                          _voiceSpeed = value;
                                        });
                                        ttsService.setVoiceSpeed(value);
                                      },
                                      onChangeEnd: (value) {
                                        _saveVoiceSpeed(authService, value);
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '0.5x',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white60
                                                  : KuwentoColors.textSecondary,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '2.0x',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? Colors.white60
                                                  : KuwentoColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_savingVoiceSpeed)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: AppSpacing.xs),
                                child: Text(
                                  'Saving speed preference...',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white60
                                            : KuwentoColors.textSecondary,
                                      ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                                'Voice quality and gender depend on your device’s installed Text-to-Speech engine and available voices.',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white60
                                          : KuwentoColors.textSecondary,
                                    )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Frequently Asked Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white : KuwentoColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? KuwentoColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: List.generate(_faqItems.length, (index) {
                      final item = _faqItems[index];
                      final isExpanded = _expandedFaqItems.contains(index);

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              index == _faqItems.length - 1 ? 0 : AppSpacing.sm,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.04)
                                : KuwentoColors.backgroundLight,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isExpanded
                                  ? KuwentoColors.pastelBlue
                                      .withValues(alpha: 0.5)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : KuwentoColors.creamDark),
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              splashColor: KuwentoColors.pastelBlue
                                  .withValues(alpha: 0.12),
                              highlightColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 2,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                0,
                                AppSpacing.md,
                                AppSpacing.md,
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  if (expanded) {
                                    _expandedFaqItems.add(index);
                                  } else {
                                    _expandedFaqItems.remove(index);
                                  }
                                });
                              },
                              trailing: AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 220),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: KuwentoColors.pastelBlue,
                                ),
                              ),
                              title: Text(
                                item['question']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : KuwentoColors.textPrimary,
                                    ),
                              ),
                              children: [
                                Text(
                                  item['answer']!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        height: 1.5,
                                        color: isDark
                                            ? Colors.white70
                                            : KuwentoColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Account actions
                if (!authService.isGuest) ...[
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : KuwentoColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? KuwentoColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: KuwentoColors.softCoral,
                      ),
                      title: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: KuwentoColors.softCoral,
                        ),
                      ),
                      onTap: () => _confirmAndSignOut(authService),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md + bottomInset,
            child: Builder(
              builder: (context) {
                return Transform.translate(
                  offset: const Offset(0, -18),
                  child: BuddyCompanion(
                    state: BuddyState.encouraging,
                    size: 72,
                    showSpeechBubble: true,
                    enableTapSpeechBubble: true,
                    message:
                        'You can adjust reading preferences here to make stories easier and more fun.',
                    speechTitle: 'Did You Know?',
                    bodyColor: KuwentoColors.pastelBlue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : KuwentoColors.textPrimary,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isDark ? Colors.white70 : KuwentoColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
