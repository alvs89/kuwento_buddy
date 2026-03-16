import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kuwentobuddy/controllers/story_controller.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/question_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';
import 'package:kuwentobuddy/services/tts_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/translation_service.dart';
import 'package:kuwentobuddy/theme.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';
import 'package:kuwentobuddy/widgets/celebration_overlay.dart';

/// Story Session Screen - The "Now Playing" reading interface
/// Implements the "Read-Think-Continue" interactive module with TTS
class StorySessionScreen extends StatefulWidget {
  final String storyId;

  const StorySessionScreen({super.key, required this.storyId});

  @override
  State<StorySessionScreen> createState() => _StorySessionScreenState();
}

class _StorySessionScreenState extends State<StorySessionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  StoryController? _controller;
  late PageController _pageController;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  final ToastService _toastService = ToastService();
  final TranslationService _translationService = TranslationService();
  bool _showBuddyOverlay = false;
  bool _isTTSEnabled = true;
  bool _showCelebration = false;
  StoryModel? _story;
  int? _recentWrongAnswerIndex;
  Timer? _wrongAnswerHighlightTimer;
  final Map<String, String> _translatedSegmentCache = {};
  final Map<String, String> _translatedQuestionCache = {};
  String _activeLanguageCode = 'en';
  bool _isTranslating = false;
  bool _isNarrationPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStory();
    context.read<TTSService>().addListener(_onTTSStateChanged);
    _pageController = PageController();

    // Overlay animation
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOutBack,
    );
  }

  void _onTTSStateChanged() {
    if (!mounted) return;

    final ttsService = context.read<TTSService>();
    if (_isNarrationPlaying != ttsService.isSpeaking) {
      setState(() {
        _isNarrationPlaying = ttsService.isSpeaking;
      });
    }
  }

  void _loadStory() {
    final story = StoryService().getStoryById(widget.storyId);
    if (story != null) {
      setState(() {
        _story = story;
        _controller = StoryController(story: story);
        _controller!.addListener(_onControllerUpdate);
        _activeLanguageCode = _sourceLanguageCode;
      });
    }
  }

  void _onControllerUpdate() {
    setState(() {});
    if (_controller?.sessionState == SessionState.questioning &&
        !_showBuddyOverlay) {
      _showBuddyQuestion();
    }
    if (_controller?.sessionState == SessionState.completed &&
        !_showCelebration) {
      setState(() => _showCelebration = true);
    }
  }

  void _showBuddyQuestion() {
    setState(() => _showBuddyOverlay = true);
    _overlayController.forward();
    HapticFeedback.mediumImpact();
    unawaited(_ensureCurrentQuestionTranslation());
  }

  void _hideBuddyQuestion() {
    _overlayController.reverse().then((_) {
      if (mounted) {
        setState(() => _showBuddyOverlay = false);
      }
    });
  }

  Future<void> _speakText(String text, {required String languageCode}) async {
    if (!_isTTSEnabled) return;
    final ttsService = context.read<TTSService>();
    await ttsService.speak(
      text,
      language: languageCode == 'fil' ? 'fil-PH' : 'en-US',
    );
  }

  Future<void> _stopSpeaking() async {
    if (mounted && _isNarrationPlaying) {
      setState(() {
        _isNarrationPlaying = false;
      });
    }
    final ttsService = context.read<TTSService>();
    await ttsService.stop();
  }

  void _stopSpeakingSilently() {
    final ttsService = context.read<TTSService>();
    if (_isNarrationPlaying) {
      _isNarrationPlaying = false;
    }
    unawaited(ttsService.stop());
  }

  Future<void> _toggleNarrationPlayback() async {
    final ttsService = context.read<TTSService>();
    final isCurrentlyPlaying = _isNarrationPlaying || ttsService.isSpeaking;

    if (isCurrentlyPlaying) {
      setState(() {
        _isNarrationPlaying = false;
      });
      await ttsService.pause();
      return;
    }

    setState(() {
      _isNarrationPlaying = true;
    });

    try {
      await _speakCurrentSegment();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isNarrationPlaying = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user == null || _story == null) return;

    final isNowFavorite = await authService.toggleFavoriteStory(
      _story!.id,
      storyTitle: _story!.title,
    );
    if (isNowFavorite) {
      _toastService.showSuccess('Added to favorites! ❤️');
    } else {
      _toastService.showInfo('Removed from favorites');
    }
  }

  String get _sourceLanguageCode =>
      (_story?.language ?? 'en') == 'fil' ? 'fil' : 'en';

  String get _targetLanguageCode => _activeLanguageCode == 'en' ? 'fil' : 'en';

  String _translationCacheKey(String segmentId, String langCode) =>
      '$segmentId::$langCode';

  String _questionCacheKey(String text, String langCode) =>
      '$langCode::${text.trim()}';

  String _translatedQuestionText(String text) {
    if (_activeLanguageCode == _sourceLanguageCode) {
      return text;
    }

    return _translatedQuestionCache[
            _questionCacheKey(text, _activeLanguageCode)] ??
        text;
  }

  String? _getDisplayedSegmentText(StorySegment segment) {
    if (_activeLanguageCode == _sourceLanguageCode) {
      return segment.content;
    }

    return _translatedSegmentCache[
        _translationCacheKey(segment.id, _activeLanguageCode)];
  }

  Future<String> _getTextForLanguage(
      StorySegment segment, String languageCode) async {
    if (languageCode == _sourceLanguageCode) {
      return segment.content;
    }

    final key = _translationCacheKey(segment.id, languageCode);
    final cached = _translatedSegmentCache[key];
    if (cached != null) {
      return cached;
    }

    final translated = await _translationService.translateText(
      text: segment.content,
      sourceLanguage: _sourceLanguageCode,
      targetLanguage: languageCode,
    );

    if (!mounted) return translated;

    setState(() {
      _translatedSegmentCache[key] = translated;
    });

    return translated;
  }

  Future<void> _ensureCurrentSegmentTranslation() async {
    if (_controller == null || _story == null) return;
    if (_activeLanguageCode == _sourceLanguageCode) return;

    final segment = _controller!.currentSegment;
    await _getTextForLanguage(segment, _activeLanguageCode);
  }

  Future<void> _ensureCurrentQuestionTranslation() async {
    if (_controller == null || _story == null) return;
    if (_activeLanguageCode == _sourceLanguageCode) return;

    final question = _controller!.currentQuestion;
    if (question == null) return;

    final texts = <String>[
      question.question,
      ...question.options,
      question.hint,
      question.encouragement,
      question.skillDisplayName,
    ];

    final updates = <String, String>{};
    for (final text in texts) {
      final key = _questionCacheKey(text, _activeLanguageCode);
      if (_translatedQuestionCache.containsKey(key)) continue;

      final translated = await _translationService.translateText(
        text: text,
        sourceLanguage: _sourceLanguageCode,
        targetLanguage: _activeLanguageCode,
      );
      updates[key] = translated;
    }

    if (!mounted || updates.isEmpty) return;

    setState(() {
      _translatedQuestionCache.addAll(updates);
    });
  }

  Future<void> _toggleStoryLanguage() async {
    if (_story == null || _controller == null) return;

    final nextLanguage = _targetLanguageCode;
    setState(() {
      _activeLanguageCode = nextLanguage;
      _isTranslating = true;
    });

    await _ensureCurrentSegmentTranslation();
    await _ensureCurrentQuestionTranslation();

    if (!mounted) return;

    setState(() {
      _isTranslating = false;
    });

    _toastService.showInfo(
      _activeLanguageCode == 'fil' ? 'Filipino mode' : 'English mode',
    );
  }

  Future<void> _speakCurrentSegment() async {
    if (_controller == null) return;
    final narrationLanguageCode = _activeLanguageCode;
    final segment = _controller!.currentSegment;
    final text = await _getTextForLanguage(segment, narrationLanguageCode);
    await _speakText(text, languageCode: narrationLanguageCode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _stopSpeakingSilently();
    }
  }

  @override
  void dispose() {
    _wrongAnswerHighlightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _stopSpeakingSilently();
    context.read<TTSService>().removeListener(_onTTSStateChanged);
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    _pageController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_story == null || _controller == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: KuwentoColors.pastelBlue,
          ),
        ),
      );
    }

    final controller = _controller!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ttsService = context.watch<TTSService>();
    final authService = context.watch<AuthService>();
    final isFavorite =
        authService.currentUser?.favoriteStoryIds.contains(_story!.id) ?? false;

    return PopScope(
      onPopInvokedWithResult: (_, __) {
        _stopSpeakingSilently();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header with progress bar
                  _buildHeader(context, isDark, ttsService, isFavorite),

                  // Story content
                  Expanded(
                    child: _buildStoryContent(context, isDark),
                  ),

                  // Navigation controls
                  _buildNavigationControls(context, isDark, ttsService),
                ],
              ),
            ),

            // Floating Buddy at bottom right (thumb zone)
            if (!_showBuddyOverlay && !_showCelebration)
              Positioned(
                right: 16,
                bottom: 100,
                child: GestureDetector(
                  onTap: () {
                    if (controller.hasCheckpoint &&
                        !controller.isAnswerCorrect) {
                      controller.triggerCheckpoint();
                    } else {
                      _toastService
                          .showInfo('Keep reading! A question is coming soon.');
                    }
                  },
                  child: BuddyCompanion(
                    state:
                        controller.hasCheckpoint && !controller.isAnswerCorrect
                            ? BuddyState.thinking
                            : BuddyState.idle,
                    size: 60,
                    showSpeechBubble: false,
                  ),
                ),
              ),

            // Buddy Question Overlay
            if (_showBuddyOverlay && !_showCelebration)
              _buildBuddyOverlay(context, isDark),

            // Celebration Overlay
            if (_showCelebration)
              CelebrationOverlay(
                starsEarned: controller.starsEarned,
                comprehensionScore: controller.comprehensionScore,
                storyTitle: _story!.title,
                onReadAgain: () {
                  _stopSpeakingSilently();
                  setState(() => _showCelebration = false);
                  controller.resetSession();
                  _pageController.jumpToPage(0);
                },
                onActivity: () {
                  _stopSpeakingSilently();
                  setState(() => _showCelebration = false);
                  context.push('/activity/${_story!.id}');
                },
                onBackToLibrary: () {
                  _stopSpeakingSilently();
                  setState(() => _showCelebration = false);
                  context.pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, TTSService ttsService,
      bool isFavorite) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Top row with close button and title
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _stopSpeaking();
                  context.pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                  size: 28,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'READING NOW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? Colors.white54
                                : KuwentoColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                    ),
                    Text(
                      _story!.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : KuwentoColors.textPrimary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red
                      : (isDark ? Colors.white54 : KuwentoColors.textMuted),
                ),
              ),
              IconButton(
                onPressed: _toggleStoryLanguage,
                icon: Icon(
                  Icons.translate,
                  color: _activeLanguageCode == _sourceLanguageCode
                      ? (isDark ? Colors.white54 : KuwentoColors.textMuted)
                      : KuwentoColors.pastelBlue,
                ),
                tooltip:
                    'Switch to ${_targetLanguageCode == 'fil' ? 'Filipino' : 'English'}',
              ),
              // TTS toggle button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isTTSEnabled = !_isTTSEnabled;
                  });
                  if (!_isTTSEnabled) {
                    _stopSpeaking();
                  }
                  _toastService.showInfo(
                    _isTTSEnabled ? 'Voice enabled' : 'Voice disabled',
                  );
                },
                icon: Icon(
                  _isTTSEnabled ? Icons.volume_up : Icons.volume_off,
                  color: _isTTSEnabled
                      ? KuwentoColors.pastelBlue
                      : (isDark ? Colors.white54 : KuwentoColors.textMuted),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Progress bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _controller!.progress,
                  backgroundColor:
                      isDark ? Colors.white12 : KuwentoColors.creamDark,
                  valueColor: AlwaysStoppedAnimation(KuwentoColors.pastelBlue),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Part ${_controller!.currentSegmentIndex + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              isDark ? Colors.white54 : KuwentoColors.textMuted,
                        ),
                  ),
                  if (_controller!.correctAnswers > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: KuwentoColors.buddyHappy,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_controller!.correctAnswers}/${_controller!.totalQuestions}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: KuwentoColors.buddyHappy,
                                  ),
                        ),
                      ],
                    ),
                  Text(
                    '${_controller!.totalSegments} parts',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              isDark ? Colors.white54 : KuwentoColors.textMuted,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KuwentoColors.pastelBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'Language: ${_activeLanguageCode == 'fil' ? 'Filipino' : 'English'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: KuwentoColors.pastelBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, bool isDark) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller!.totalSegments,
      onPageChanged: (index) {
        _controller!.goToSegment(index);
        _ensureCurrentSegmentTranslation();
      },
      itemBuilder: (context, index) {
        final segment = _story!.segments[index];
        final displayedSegmentText = _getDisplayedSegmentText(segment);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSegmentImage(segment, index),
              const SizedBox(height: AppSpacing.lg),

              // Story text (single active language view)
              if (displayedSegmentText == null ||
                  (index == _controller!.currentSegmentIndex && _isTranslating))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: KuwentoColors.pastelBlue,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Translating story...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : KuwentoColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  displayedSegmentText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: FontSizes.storyText,
                        height: 1.8,
                        color:
                            isDark ? Colors.white : KuwentoColors.textPrimary,
                      ),
                ),

              // Checkpoint indicator
              if (segment.question != null &&
                  !_controller!.isAnswerCorrect) ...[
                const SizedBox(height: AppSpacing.xl),
                _buildCheckpointIndicator(context, isDark),
              ],

              const SizedBox(height: 150),
            ],
          ),
        );
      },
    );
  }

  // Placeholder images for segments; replace these paths/URLs later with final art.
  static const List<String> _placeholderSegmentImages = [
    'assets/images/underwater_ocean_mermaid_children_story_null_1773063136715.png',
    'assets/images/tropical_jungle_adventure_children_illustration_null_1773063139698.jpg',
    'assets/images/dragon_castle_fantasy_children_illustration_null_1773063135821.jpg',
    'assets/images/rice_terraces_Philippines_landscape_beautiful_null_1773063138652.jpg',
    'assets/images/magical_forest_fairy_tale_children_book_illustration_null_1773063134827.jpg',
    'assets/images/friendly_owl_forest_children_book_null_1773063137821.jpg',
  ];

  Widget _buildSegmentImage(StorySegment segment, int index) {
    final imagePath = _resolveSegmentImage(segment, index);

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: KuwentoColors.pastelBlue.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: KuwentoColors.pastelBlue.withValues(alpha: 0.2),
            child: const Icon(
              Icons.auto_stories,
              size: 64,
              color: KuwentoColors.pastelBlue,
            ),
          ),
        ),
      ),
    );

    if (index == 0) {
      return Hero(
        tag: 'story_cover_${_story!.id}',
        child: card,
      );
    }

    return card;
  }

  String _resolveSegmentImage(StorySegment segment, int index) {
    // 1) Explicit per-segment image wins
    if (segment.image != null && segment.image!.isNotEmpty) {
      return segment.image!;
    }

    // 2) Guaranteed unique placeholder per segment index
    return _placeholderSegmentImages[index % _placeholderSegmentImages.length];
  }

  Widget _buildCheckpointIndicator(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _controller!.triggerCheckpoint(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: KuwentoColors.pastelBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: KuwentoColors.pastelBlue.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const BuddyCompanion(
              state: BuddyState.thinking,
              size: 50,
              showSpeechBubble: false,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading Checkpoint!',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: KuwentoColors.pastelBlue,
                        ),
                  ),
                  Text(
                    'Tap to answer a question before continuing',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white70
                              : KuwentoColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: KuwentoColors.pastelBlue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationControls(
      BuildContext context, bool isDark, TTSService ttsService) {
    final isCompleted = _controller!.isCompleted;
    final isNarrationPlaying = _isNarrationPlaying || ttsService.isSpeaking;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? KuwentoColors.cardDark : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          IconButton(
            onPressed: _controller!.canGoPrevious
                ? () {
                    _stopSpeaking();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    _controller!.goToPrevious();
                  }
                : null,
            icon: Icon(
              Icons.skip_previous,
              size: 32,
              color: _controller!.canGoPrevious
                  ? (isDark ? Colors.white : KuwentoColors.textPrimary)
                  : (isDark ? Colors.white24 : KuwentoColors.textMuted),
            ),
          ),

          // Read aloud button
          IconButton(
            onPressed: _toggleNarrationPlayback,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isNarrationPlaying ? Icons.pause_circle : Icons.play_circle,
                key: ValueKey<bool>(isNarrationPlaying),
                size: 40,
                color: KuwentoColors.pastelBlue,
              ),
            ),
          ),

          // Main action button
          GestureDetector(
            onTap: () {
              _stopSpeaking();
              if (isCompleted) {
                setState(() => _showCelebration = true);
              } else if (_controller!.hasCheckpoint &&
                  !_controller!.isAnswerCorrect) {
                _controller!.triggerCheckpoint();
              } else if (_controller!.canGoNext) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                _controller!.goToNext();
              }
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isCompleted
                    ? KuwentoColors.buddyHappy
                    : KuwentoColors.pastelBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.celebration
                    : (_controller!.hasCheckpoint &&
                            !_controller!.isAnswerCorrect)
                        ? Icons.quiz
                        : Icons.arrow_forward,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          // Next button
          IconButton(
            onPressed: _controller!.canGoNext && !_controller!.hasCheckpoint
                ? () {
                    _stopSpeaking();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    _controller!.goToNext();
                  }
                : null,
            icon: Icon(
              Icons.skip_next,
              size: 32,
              color: (_controller!.canGoNext && !_controller!.hasCheckpoint)
                  ? (isDark ? Colors.white : KuwentoColors.textPrimary)
                  : (isDark ? Colors.white24 : KuwentoColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuddyOverlay(BuildContext context, bool isDark) {
    final question = _controller!.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final displaySkill = _translatedQuestionText(question.skillDisplayName);
    final displayQuestion = _translatedQuestionText(question.question);
    final displayOptions =
        question.options.map(_translatedQuestionText).toList(growable: false);
    final displayHint = _translatedQuestionText(question.hint);
    final displayEncouragement =
        _translatedQuestionText(question.encouragement);

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) => Transform.scale(
              scale: _overlayAnimation.value,
              child: child,
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Buddy companion with appropriate state
                    BuddyCompanion(
                      state: _controller!.isAnswerCorrect
                          ? BuddyState.happy
                          : (_controller!.showHint
                              ? BuddyState.sympathetic
                              : BuddyState.thinking),
                      message: _controller!.isAnswerCorrect
                          ? displayEncouragement
                          : (_controller!.showHint ? displayHint : null),
                      size: 100,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Skill badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: KuwentoColors.pastelBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text(
                        displaySkill,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: KuwentoColors.pastelBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark ? KuwentoColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayQuestion,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : KuwentoColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Answer options
                          ...List.generate(
                            question.options.length,
                            (index) => _buildAnswerOption(
                              context,
                              isDark,
                              index,
                              displayOptions[index],
                              question,
                            ),
                          ),

                          // "Back to Read Story Again" button (when not correct yet)
                          if (!_controller!.isAnswerCorrect) ...[
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () {
                                  _hideBuddyQuestion();
                                  _controller!.goBackToReading();
                                },
                                icon: Icon(
                                  Icons.menu_book,
                                  size: 18,
                                  color: KuwentoColors.pastelBlue,
                                ),
                                label: Text(
                                  'Back to Read Story Again',
                                  style: TextStyle(
                                    color: KuwentoColors.pastelBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // Continue button (if correct)
                          if (_controller!.isAnswerCorrect) ...[
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _hideBuddyQuestion();
                                  Future.delayed(
                                    const Duration(milliseconds: 400),
                                    () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                      _controller!.continueAfterCorrect();
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KuwentoColors.buddyHappy,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Continue Reading ✨',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
    BuildContext context,
    bool isDark,
    int index,
    String option,
    QuestionModel question,
  ) {
    final isSelected = _controller!.selectedAnswerIndex == index;
    final isCorrect = question.isCorrect(index);
    final isTemporarilyWrong = _recentWrongAnswerIndex == index;
    final hasAnsweredCorrectly = _controller!.isAnswerCorrect;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? iconData;

    if (hasAnsweredCorrectly && isCorrect) {
      // Correct answer selected - show green
      backgroundColor = KuwentoColors.buddyHappy.withValues(alpha: 0.2);
      borderColor = KuwentoColors.buddyHappy;
      textColor = KuwentoColors.buddyHappy;
      iconData = Icons.check;
    } else if (isTemporarilyWrong) {
      // Wrong answer should highlight briefly, then return to default.
      backgroundColor = KuwentoColors.softCoral.withValues(alpha: 0.1);
      borderColor = KuwentoColors.softCoral.withValues(alpha: 0.3);
      textColor = KuwentoColors.softCoral;
      iconData = null;
    } else {
      // Default state - available option
      backgroundColor = Colors.transparent;
      borderColor = isDark ? Colors.white24 : KuwentoColors.creamDark;
      textColor = isDark ? Colors.white : KuwentoColors.textPrimary;
      iconData = null;
    }

    final isDisabled = hasAnsweredCorrectly;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                HapticFeedback.selectionClick();
                _controller!.submitAnswer(index);
                if (!question.isCorrect(index)) {
                  _wrongAnswerHighlightTimer?.cancel();
                  setState(() => _recentWrongAnswerIndex = index);
                  _wrongAnswerHighlightTimer = Timer(
                    const Duration(milliseconds: 650),
                    () {
                      if (mounted) {
                        setState(() => _recentWrongAnswerIndex = null);
                      }
                    },
                  );
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: iconData != null
                      ? Icon(iconData, color: textColor, size: 16)
                      : Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
