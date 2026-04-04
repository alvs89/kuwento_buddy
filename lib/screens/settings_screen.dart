import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:kuwentobuddy/services/tts_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';
import 'package:kuwentobuddy/widgets/profile_avatar.dart';

/// Settings screen for user preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ToastService _toastService = ToastService();
  final Set<int> _expandedFaqItems = <int>{};

  double _voiceSpeed = 1.0;
  bool _speedInitialized = false;
  bool _savingVoiceSpeed = false;
  bool _isSigningOut = false;

  static const List<_FaqSectionData> _faqSections = [
    _FaqSectionData(
      title: 'Getting Started',
      items: [
        _FaqItemData(
          id: 0,
          question: 'How do I start reading a story?',
          answer:
              'Go to the Library tab, choose a story card, then tap it to open the reading session. Use the next button to move through each part.',
        ),
        _FaqItemData(
          id: 1,
          question: 'Can I read in English and Filipino?',
          answer:
              'Yes. During a story session, tap the translate icon in the header to switch between English and Filipino.',
        ),
        _FaqItemData(
          id: 2,
          question: 'How do I use voice narration?',
          answer:
              'To use voice narration, simply tap the narration button (found in the bottom controls of the story session) to start listening to the story. If you pause and then tap the resume button, please note that the text-to-speech (TTS) currently restarts reading from the beginning of the section or title rather than resuming exactly where it left off.\n\nWe understand this may be inconvenient, and we’re working on improving this feature in future updates to provide a smoother listening experience. Thank you for your patience and understanding.',
        ),
      ],
    ),
    _FaqSectionData(
      title: 'Comprehension and Scoring',
      items: [
        _FaqItemData(
          id: 3,
          question: 'How does KuwentoBuddy improve comprehension?',
          answer:
              'The app adds checkpoints and short questions while reading so learners think about the story, not just finish it quickly.',
        ),
        _FaqItemData(
          id: 4,
          question: 'How are comprehension scores and stars calculated?',
          answer:
              'Your comprehension score comes from the checkpoint questions in the story. Each question is counted once when you answer it the first time. If your first answer is correct, it counts as a good answer. If the first answer is wrong, the question still counts, but it does not count as correct.\n\nThe app then finds your score by dividing the number of correct first answers by the total number of questions, then multiplying by 100. After the story ends, that score becomes your stars: 3 stars for 90% or higher, 2 stars for 70% to 89%, 1 star for 50% to 69%, and 0 stars below 50%.',
        ),
        _FaqItemData(
          id: 5,
          question: 'How is inference calculated?',
          answer:
              'Inference questions ask you to figure out something the story does not say directly. The app counts how many inference questions you answer on the first try and how many of those are correct. Your inference score is the number of correct first answers divided by all inference questions, then multiplied by 100.',
        ),
        _FaqItemData(
          id: 6,
          question: 'How is prediction calculated?',
          answer:
              'Prediction questions ask what you think will happen next. The app counts how many prediction questions you answer on the first try and how many of those are correct. Your prediction score is the number of correct first answers divided by all prediction questions, then multiplied by 100.',
        ),
        _FaqItemData(
          id: 7,
          question: 'How is emotion calculated?',
          answer:
              'Emotion questions ask how a character feels. The app counts how many emotion questions you answer on the first try and how many of those are correct. Your emotion score is the number of correct first answers divided by all emotion questions, then multiplied by 100.',
        ),
      ],
    ),
    _FaqSectionData(
      title: 'Progress and Saving',
      items: [
        _FaqItemData(
          id: 8,
          question: 'Will my progress be saved?',
          answer:
              'Yes. If you sign in, your stars, completed stories, and favorites can be synced. Guest mode works instantly for quick reading.',
        ),
      ],
    ),
  ];

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

    final updatedPreferences = user.preferences.copyWith(voiceSpeed: value);
    final updatedUser = user.copyWith(preferences: updatedPreferences);

    await authService.updateUser(updatedUser);

    if (!mounted) return;
    setState(() {
      _savingVoiceSpeed = false;
    });
    _toastService.showSuccess('Voice speed saved');
  }

  Future<void> _confirmAndSignOut(AuthService authService) async {
    if (_isSigningOut) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
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

    setState(() => _isSigningOut = true);
    try {
      await authService.signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    } finally {
      if (mounted) {
        GoRouter.of(context).go('/login');
        setState(() => _isSigningOut = false);
      }
    }
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? KuwentoColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        label: user?.displayName ?? user?.firstName ?? 'Reader',
                        source: photoUrl,
                        size: 60,
                        accentColor: KuwentoColors.pastelBlue,
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
                                        'Story Narration',
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
                                        'Adjust how fast stories are read aloud during playback.',
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
                                      const Icon(
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
                                              AppRadius.md),
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
                              'Voice quality and gender depend on your device\'s installed Text-to-Speech engine and available voices.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        List.generate(_faqSections.length, (sectionIndex) {
                      final section = _faqSections[sectionIndex];

                      return _buildFaqSection(
                        context,
                        isDark,
                        section,
                        isLastSection: sectionIndex == _faqSections.length - 1,
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildAboutSection(context, isDark),
                const SizedBox(height: AppSpacing.xl),
                if (user != null && !user.isGuest) ...[
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
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.switch_account_rounded,
                            color: KuwentoColors.skyBlue,
                          ),
                          title: Text(
                            'Switch Profiles',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : KuwentoColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            final authCtx = context.read<AuthService>();
                            authCtx.switchToParentView();
                            GoRouter.of(context).go('/profile-selection');
                          },
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color:
                              isDark ? Colors.white12 : KuwentoColors.creamDark,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: KuwentoColors.softCoral,
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(color: KuwentoColors.softCoral),
                          ),
                          onTap: () => _confirmAndSignOut(authService),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md + bottomInset,
            child: Transform.translate(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(
    BuildContext context,
    bool isDark,
    _FaqSectionData section, {
    required bool isLastSection,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastSection ? 0 : AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: KuwentoColors.pastelBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? KuwentoColors.buddyHappy
                          : KuwentoColors.deepTeal,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            children: List.generate(section.items.length, (itemIndex) {
              final item = section.items[itemIndex];

              return _buildFaqItem(
                context,
                isDark,
                item,
                isLastItem: itemIndex == section.items.length - 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    bool isDark,
    _FaqItemData item, {
    required bool isLastItem,
  }) {
    final isExpanded = _expandedFaqItems.contains(item.id);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastItem ? 0 : AppSpacing.sm,
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
                ? KuwentoColors.pastelBlue.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : KuwentoColors.creamDark),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: KuwentoColors.pastelBlue.withValues(alpha: 0.12),
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
                  _expandedFaqItems.add(item.id);
                } else {
                  _expandedFaqItems.remove(item.id);
                }
              });
            },
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: KuwentoColors.pastelBlue,
              ),
            ),
            title: Text(
              item.question,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : KuwentoColors.textPrimary,
                  ),
            ),
            children: [
              Text(
                item.answer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color:
                          isDark ? Colors.white70 : KuwentoColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About The App',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : KuwentoColors.textPrimary,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAboutBlock(
                context,
                isDark: isDark,
                title: 'What Kuwento Buddy is about',
                body:
                    'Kuwento Buddy is a story-reading app that helps learners enjoy engaging tales while building comprehension through guided reading, questions, and narration support.',
                accent: KuwentoColors.buddyHappy,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildAboutBlock(
                context,
                isDark: isDark,
                title: 'AI-generated images',
                body:
                    'AI-generated images are used for avatars, cover photos, and story segments to enrich your experience. We strive to provide engaging and visually appealing content while maintaining transparency about our use of AI technology.',
                accent: KuwentoColors.pastelBlue,
                highlighted: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutBlock(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String body,
    required Color accent,
    bool highlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted
            ? accent.withValues(alpha: isDark ? 0.12 : 0.08)
            : (isDark
                ? Colors.white.withValues(alpha: 0.03)
                : KuwentoColors.backgroundLight),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: highlighted
              ? accent.withValues(alpha: 0.22)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : KuwentoColors.creamDark),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              highlighted
                  ? Icons.auto_awesome_outlined
                  : Icons.info_outline_rounded,
              size: 16,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? Colors.white : KuwentoColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.6,
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

class _FaqSectionData {
  final String title;
  final List<_FaqItemData> items;

  const _FaqSectionData({
    required this.title,
    required this.items,
  });
}

class _FaqItemData {
  final int id;
  final String question;
  final String answer;

  const _FaqItemData({
    required this.id,
    required this.question,
    required this.answer,
  });
}
