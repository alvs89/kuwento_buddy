import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
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
import 'package:kuwentobuddy/widgets/ai_generated_image_note.dart';
import 'package:kuwentobuddy/widgets/buddy_companion.dart';
import 'package:kuwentobuddy/widgets/celebration_overlay.dart';

/// Story Session Screen - The "Now Playing" reading interface
/// Implements the "Read-Think-Continue" interactive module with TTS
class StorySessionScreen extends StatefulWidget {
  final String storyId;
  final bool resumeProgress;

  const StorySessionScreen({
    super.key,
    required this.storyId,
    this.resumeProgress = false,
  });

  @override
  State<StorySessionScreen> createState() => _StorySessionScreenState();
}

class _StorySessionScreenState extends State<StorySessionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const Duration _hintBubbleDuration = Duration(seconds: 8);
  static const String _correctAnswerSoundAsset = 'audio/correct_answer.wav';
  static const String _wrongAnswerSoundAsset = 'audio/wrong_answer.wav';
  static const double _answerFeedbackVolume = 0.9;

  StoryController? _controller;
  late PageController _pageController;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  final ToastService _toastService = ToastService();
  final TranslationService _translationService = TranslationService();
  bool _showBuddyOverlay = false;
  bool _showCelebration = false;
  StoryModel? _story;
  int? _recentWrongAnswerIndex;
  Timer? _wrongAnswerHighlightTimer;
  final Map<String, String> _translatedTitleCache = {};
  final Map<String, String> _translatedSegmentCache = {};
  final Map<String, String> _translatedQuestionCache = {};
  late final AudioContext _answerFeedbackAudioContext;
  AudioPool? _correctAnswerAudioPool;
  AudioPool? _wrongAnswerAudioPool;
  StopFunction? _activeAnswerFeedbackStop;
  String _activeLanguageCode = 'en';
  bool _isTranslating = false;
  bool _isNarrationPlaying = false;
  bool _isExiting = false;
  bool _suppressBuddyHints = false;
  bool _showQuestionHintBubble = false;
  bool _showQuestionSuccessBubble = false;
  int _hintBubblePresentationId = 0;
  Timer? _hintBubbleTimer;
  Timer? _successBubbleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _answerFeedbackAudioContext = AudioContextConfig(
      route: AudioContextConfigRoute.speaker,
      focus: AudioContextConfigFocus.gain,
      respectSilence: false,
    ).build();
    unawaited(_prepareAnswerFeedbackAudio());
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

  Future<void> _prepareAnswerFeedbackAudio() async {
    try {
      await AudioPlayer.global.setAudioContext(_answerFeedbackAudioContext);
      _correctAnswerAudioPool = await AudioPool.create(
        source: AssetSource(_correctAnswerSoundAsset),
        maxPlayers: 1,
        minPlayers: 1,
        playerMode: PlayerMode.lowLatency,
        audioContext: _answerFeedbackAudioContext,
      );
      _wrongAnswerAudioPool = await AudioPool.create(
        source: AssetSource(_wrongAnswerSoundAsset),
        maxPlayers: 1,
        minPlayers: 1,
        playerMode: PlayerMode.lowLatency,
        audioContext: _answerFeedbackAudioContext,
      );
    } catch (error) {
      debugPrint('Answer feedback audio failed to prepare: $error');
    }
  }

  Future<void> _playAnswerFeedbackSound({required bool isCorrect}) async {
    try {
      final selectedPool =
          isCorrect ? _correctAnswerAudioPool : _wrongAnswerAudioPool;
      if (selectedPool == null) return;

      final previousStop = _activeAnswerFeedbackStop;
      _activeAnswerFeedbackStop = null;
      if (previousStop != null) {
        await previousStop();
      }

      _activeAnswerFeedbackStop = await selectedPool.start(
        volume: _answerFeedbackVolume,
      );
    } catch (error) {
      debugPrint('Answer feedback audio failed to play: $error');
    }
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
        _controller = StoryController(
          story: story,
          resumeProgress: widget.resumeProgress,
        );
        _controller!.addListener(_onControllerUpdate);
        _activeLanguageCode = _sourceLanguageCode;
      });

      // Persist an in-progress entry immediately so the Library tab reflects
      // the story without waiting for further interaction.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_prefetchAllTranslations(_activeLanguageCode));
        unawaited(_controller?.saveProgress(immediate: true));
        // Keep AuthService cache in sync so My Library shows the card instantly.
        final auth = context.read<AuthService>();
        unawaited(auth.refreshCurrentUserFromCloud());
      });
    }
  }

  void _onControllerUpdate() {
    setState(() {});
    _syncPageControllerToCurrentSegment();
    final remainingHints = _controller?.remainingHintAttempts ?? 0;

    // Suppress buddy/hints for the rest of this session once hints are exhausted.
    if (remainingHints <= 0 &&
        !_suppressBuddyHints &&
        _controller?.showHint != true) {
      _suppressBuddyHints = true;
    }

    if (_controller?.sessionState == SessionState.questioning &&
        !_showBuddyOverlay) {
      _showBuddyQuestion();
    }
    if (_controller?.sessionState == SessionState.completed &&
        !_showCelebration) {
      _suppressBuddyHints = false; // hints replenish after completion
      setState(() => _showCelebration = true);
    }
    if (_controller?.sessionState == SessionState.questioning) {
      if (_suppressBuddyHints) {
        _hideHintBubble();
      } else if (_controller?.showHint == true) {
        if (!_showQuestionHintBubble) {
          _startHintBubble();
        }
      } else {
        _hideHintBubble();
      }
      if (_controller?.isAnswerCorrect == true) {
        _startSuccessBubble();
      } else {
        _hideSuccessBubble();
      }
    } else {
      _hideHintBubble();
      _hideSuccessBubble();
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
    _hideHintBubble();
    _hideSuccessBubble();
  }

  void _handleShowHintsTap() {
    if (_controller == null) return;

    final bubbleWasVisible = _showQuestionHintBubble;
    final result = _controller!.requestHint();
    if (bubbleWasVisible && result.hintShown) {
      _startHintBubble();
    }
    if (result.remainingAttempts > 0) {
      final label = result.remainingAttempts == 1
          ? _uiText(en: 'hint attempt', fil: 'pahiwatig')
          : _uiText(en: 'hint attempts', fil: 'mga pahiwatig');
      _toastService.showInfo(
        '${result.remainingAttempts} $label ${_hintRemainingText(result.remainingAttempts)}',
      );
      return;
    }

    _toastService.showWarning(_usedAllHintsLabel);
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

  void _enterFreshSession() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      _showCelebration = false;
      _showBuddyOverlay = false;
      _suppressBuddyHints = false;
      _showQuestionHintBubble = false;
      _showQuestionSuccessBubble = false;
      _hintBubblePresentationId = 0;
    });
    controller.startFreshCountedSession();
    _pageController.jumpToPage(0);
  }

  void _syncPageControllerToCurrentSegment() {
    final controller = _controller;
    if (controller == null || !_pageController.hasClients) return;

    final targetIndex = controller.currentSegmentIndex;
    final currentPage = _pageController.page?.round();
    if (currentPage == targetIndex) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final pageNow = _pageController.page?.round();
      if (pageNow != targetIndex) {
        _pageController.jumpToPage(targetIndex);
      }
    });
  }

  Future<void> _speakCurrentSegment() async {
    if (_controller == null || _story == null) return;
    final ttsService = context.read<TTSService>();
    final segment = _controller!.currentSegment;
    final text = await _getTextForLanguage(segment, _activeLanguageCode);
    final languageCode = _activeLanguageCode == 'fil' ? 'fil-PH' : 'en-US';

    if (_isOpeningPageSegment(segment, _controller!.currentSegmentIndex)) {
      await _speakOpeningPageNarration(ttsService, text);
      return;
    }

    await ttsService.speak(text, language: languageCode);
  }

  Future<void> _speakOpeningPageNarration(
    TTSService ttsService,
    String articleText,
  ) async {
    final narrationLanguage = _activeLanguageCode == 'fil' ? 'fil-PH' : 'en-US';
    final titleValue = _displayStoryTitle();
    final genreValue = _extractOpeningFieldAny(articleText, const [
      'Genre',
      'Uri',
    ]);
    final levelValue = _extractOpeningFieldAny(articleText, const [
      'Level',
      'Antas',
    ]);
    final languageValue = _extractOpeningFieldAny(articleText, const [
      'Language',
      'Wika',
    ]);
    final synopsisValue = _extractOpeningBlockAny(
      articleText,
      _openingSynopsisSectionLabels,
      [..._openingSourceSectionLabels, ..._openingHeadsUpSectionLabels],
    );
    final headsUpValue = _extractOpeningBlockAny(
      articleText,
      _openingHeadsUpSectionLabels,
      _openingSourceSectionLabels,
    );
    final sourceValue = _extractOpeningBlockAny(
      articleText,
      _openingSourceSectionLabels,
      _openingHeadsUpSectionLabels,
    );

    final narrationParts = <String>[
      if (titleValue.trim().isNotEmpty)
        _openingNarrationSection(
          _uiText(en: 'Title', fil: 'Pamagat'),
          titleValue,
        ),
      if (genreValue.trim().isNotEmpty)
        _openingNarrationSection(_uiText(en: 'Genre', fil: 'Uri'), genreValue),
      if (levelValue.trim().isNotEmpty)
        _openingNarrationSection(
          _uiText(en: 'Level', fil: 'Antas'),
          levelValue,
        ),
      if (languageValue.trim().isNotEmpty)
        _openingNarrationSection(
          _uiText(en: 'Language', fil: 'Wika'),
          languageValue,
        ),
      if (synopsisValue.trim().isNotEmpty)
        _openingNarrationSection(_synopsisLabel, synopsisValue),
      if (headsUpValue.trim().isNotEmpty)
        _openingNarrationSection(_headsUpLabel, headsUpValue),
      if (sourceValue.trim().isNotEmpty)
        _openingNarrationSection(_sourceReferenceLabel, sourceValue),
    ];

    if (narrationParts.isEmpty) return;

    final narrationText = narrationParts.join('\n\n');

    await ttsService.speak(narrationText, language: narrationLanguage);
  }

  String _openingNarrationSection(String label, String content) {
    final normalizedContent = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    final spokenContent = _ensureSentenceEnding(normalizedContent);
    return '$label. $spokenContent';
  }

  String _ensureSentenceEnding(String text) {
    if (text.isEmpty) return text;
    if (RegExp(r'[.!?…]$').hasMatch(text)) return text;
    return '$text.';
  }

  Future<void> _toggleNarrationPlayback() async {
    final ttsService = context.read<TTSService>();

    if (!ttsService.isTtsEnabled) {
      _toastService.showWarning('Voice narration is turned off in Settings.');
      return;
    }

    if (ttsService.isPaused) {
      final resumed = await ttsService.resume();
      if (resumed) {
        if (!mounted) return;
        setState(() {
          _isNarrationPlaying = true;
        });
        return;
      }
    }

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

    final isCurrentlyFavorite = user.favoriteStoryIds.contains(_story!.id);

    if (isCurrentlyFavorite) {
      _toastService.showInfo(_removedFromFavoritesLabel);
    } else {
      _toastService.showSuccess(_addedToFavoritesLabel);
    }

    await authService.toggleFavoriteStory(
      _story!.id,
      storyTitle: _story!.title,
    );
  }

  String get _sourceLanguageCode =>
      (_story?.language ?? 'en') == 'fil' ? 'fil' : 'en';

  String get _targetLanguageCode => _activeLanguageCode == 'en' ? 'fil' : 'en';

  static const Set<String> _femalePronounStoryIds = {
    'alamat-ng-pinya',
    'alamat-ng-bulkang-mayon',
    'alamat-ng-parol',
    'huni-ng-duyan-sa-punong-kawayan',
    'pamana-ng-lumang-duyan',
  };

  bool get _preferFemalePronounsForStory =>
      _story != null &&
      _femalePronounStoryIds.contains(_story!.id) &&
      _sourceLanguageCode == 'fil';

  String _translationCacheKey(String segmentId, String langCode) =>
      '$segmentId::$langCode';

  String _questionCacheKey(String text, String langCode) =>
      '$langCode::${text.trim()}';

  String _translatedQuestionText(String text) {
    if (_activeLanguageCode == _sourceLanguageCode) {
      return text;
    }

    return _translatedQuestionCache[_questionCacheKey(
          text,
          _activeLanguageCode,
        )] ??
        text;
  }

  String? _getDisplayedSegmentText(StorySegment segment) {
    if (_activeLanguageCode == _sourceLanguageCode) {
      return segment.content;
    }

    return _translatedSegmentCache[_translationCacheKey(
      segment.id,
      _activeLanguageCode,
    )];
  }

  Future<String> _getTextForLanguage(
    StorySegment segment,
    String languageCode,
  ) async {
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
      preferFemaleSubject: _preferFemalePronounsForStory,
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
    if (_isOpeningPageSegment(segment, _controller!.currentSegmentIndex)) {
      await _prefetchOpeningPageTranslation(segment, _activeLanguageCode);
    }
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
        preferFemaleSubject: _preferFemalePronounsForStory,
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

    await _prefetchAllTranslations(nextLanguage);

    if (!mounted) return;

    setState(() {
      _isTranslating = false;
    });
    _toastService.showInfo(
      nextLanguage == 'fil' ? 'Filipino mode' : 'English mode',
    );
  }

  Future<void> _saveProgressAndExit() async {
    if (_isExiting) return;

    _isExiting = true;

    _stopSpeakingSilently();

    // Fire-and-forget persistence to keep the exit flow non-blocking
    final controller = _controller;
    final auth = mounted ? context.read<AuthService>() : null;
    unawaited(
      Future(() async {
        try {
          await controller?.saveProgress(immediate: true);
          if (auth != null) {
            await auth.refreshCurrentUserFromCloud();
          }
        } catch (e) {
          debugPrint('Failed to save progress before exit: $e');
        }
      }),
    );

    if (mounted) {
      GoRouter.of(context).go('/');
    }
  }

  Future<void> _prefetchAllTranslations(String targetLanguage) async {
    final story = _story;
    if (story == null) return;

    if (targetLanguage == _sourceLanguageCode) {
      return;
    }

    final tasks = <Future<void>>[_translateStoryTitle(targetLanguage)];

    for (final segment in story.segments) {
      tasks.add(_getTextForLanguage(segment, targetLanguage).then((_) {}));
      if (_isOpeningPageSegment(segment, story.segments.indexOf(segment))) {
        tasks.add(_prefetchOpeningPageTranslation(segment, targetLanguage));
      }
      final question = segment.question;
      if (question != null) {
        tasks.add(_prefetchQuestionTranslation(question, targetLanguage));
      }
    }

    await Future.wait(tasks);
  }

  Future<void> _translateStoryTitle(String targetLanguage) async {
    final story = _story;
    if (story == null || targetLanguage == _sourceLanguageCode) return;

    final key = _storyTitleCacheKey(targetLanguage);
    if (_translatedTitleCache.containsKey(key)) return;

    final translated = await _translationService.translateText(
      text: story.title,
      sourceLanguage: _sourceLanguageCode,
      targetLanguage: targetLanguage,
      preferFemaleSubject: _preferFemalePronounsForStory,
    );

    if (!mounted) return;

    setState(() {
      _translatedTitleCache[key] = translated;
    });
  }

  Future<void> _prefetchQuestionTranslation(
    QuestionModel question,
    String targetLanguage,
  ) async {
    if (targetLanguage == _sourceLanguageCode) return;

    final texts = <String>[
      question.question,
      ...question.options,
      question.hint,
      question.encouragement,
      question.buddyHintParagraph,
    ];

    final updates = <String, String>{};
    for (final text in texts) {
      final key = _questionCacheKey(text, targetLanguage);
      if (_translatedQuestionCache.containsKey(key)) continue;

      final translated = await _translationService.translateText(
        text: text,
        sourceLanguage: _sourceLanguageCode,
        targetLanguage: targetLanguage,
        preferFemaleSubject: _preferFemalePronounsForStory,
      );
      updates[key] = translated;
    }

    if (!mounted || updates.isEmpty) return;

    setState(() {
      _translatedQuestionCache.addAll(updates);
    });
  }

  Future<void> _prefetchOpeningPageTranslation(
    StorySegment segment,
    String targetLanguage,
  ) async {
    if (targetLanguage == _sourceLanguageCode) return;

    final sourceArticleText = segment.content;
    final texts = <String>{
      _extractOpeningBlockAny(
        sourceArticleText,
        _openingSynopsisSectionLabels,
        [..._openingSourceSectionLabels, ..._openingHeadsUpSectionLabels],
      ),
      _extractOpeningBlockAny(
        sourceArticleText,
        _openingSourceSectionLabels,
        _openingHeadsUpSectionLabels,
      ),
      _extractOpeningBlockAny(
        sourceArticleText,
        _openingHeadsUpSectionLabels,
      ),
    }..removeWhere((text) => text.trim().isEmpty);

    final updates = <String, String>{};
    for (final text in texts) {
      final key = _questionCacheKey(text, targetLanguage);
      if (_translatedQuestionCache.containsKey(key)) continue;

      final translated = await _translationService.translateText(
        text: text,
        sourceLanguage: _sourceLanguageCode,
        targetLanguage: targetLanguage,
        preferFemaleSubject: _preferFemalePronounsForStory,
      );
      updates[key] = translated;
    }

    if (!mounted || updates.isEmpty) return;

    setState(() {
      _translatedQuestionCache.addAll(updates);
    });
  }

  String _displayOpeningText(String text) {
    if (_activeLanguageCode == _sourceLanguageCode) {
      return text;
    }

    return _translatedQuestionCache[
            _questionCacheKey(text, _activeLanguageCode)] ??
        text;
  }

  String _storyTitleCacheKey(String langCode) => 'story-title::$langCode';

  bool get _isFilipino => _activeLanguageCode == 'fil';

  String _uiText({required String en, required String fil}) =>
      _isFilipino ? fil : en;

  String _skillLabel(QuestionSkill skill) {
    switch (skill) {
      case QuestionSkill.inference:
        return _uiText(en: 'Understanding Why', fil: 'Pag-unawa sa Dahilan');
      case QuestionSkill.prediction:
        return _uiText(
          en: 'Predicting What Happens',
          fil: 'Paghula sa Mangyayari',
        );
      case QuestionSkill.emotion:
        return _uiText(
          en: 'Understanding Feelings',
          fil: 'Pag-unawa sa Damdamin',
        );
    }
  }

  String get _readingNowLabel =>
      _uiText(en: 'READING NOW', fil: 'BINABASA NGAYON');

  String _displayStoryTitle() {
    final story = _story;
    if (story == null) return '';

    final explicitTitle = story.explicitTitleTranslation(_activeLanguageCode);
    if (explicitTitle != null && explicitTitle.trim().isNotEmpty) {
      return explicitTitle;
    }

    final key = _storyTitleCacheKey(_activeLanguageCode);
    return _translatedTitleCache[key] ?? story.title;
  }

  String _localizedPartLabel() => _uiText(en: 'Part', fil: 'Bahagi');

  String _languageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'fil':
        return _uiText(en: 'Filipino', fil: 'Filipino');
      case 'en':
        return _uiText(en: 'English', fil: 'English');
      default:
        return languageCode.toUpperCase();
    }
  }

  String get _sectionCountLabel => _uiText(en: 'parts', fil: 'bahagi');

  String get _languageLabel => _uiText(en: 'Language', fil: 'Wika');

  String get _translatingLabel =>
      _uiText(en: 'Translating story...', fil: 'Isinasalin ang kuwento...');

  String get _switchLanguageTooltip => _uiText(
        en: 'Switch to ${_targetLanguageCode == 'fil' ? 'Filipino' : 'English'}',
        fil:
            'Lumipat sa ${_targetLanguageCode == 'fil' ? 'Filipino' : 'English'}',
      );

  String get _addedToFavoritesLabel =>
      _uiText(en: 'Added to favorites! ❤️', fil: 'Idinagdag sa paborito! ❤️');

  String get _removedFromFavoritesLabel =>
      _uiText(en: 'Removed from favorites', fil: 'Tinanggal sa paborito');

  String get _readingCheckpointTitle =>
      _uiText(en: 'Reading Checkpoint!', fil: 'Checkpoint sa Pagbasa!');

  String get _readingCheckpointSubtitle => _uiText(
        en: 'Tap to answer a question before continuing',
        fil: 'I-tap upang sagutin ang tanong bago magpatuloy',
      );

  String get _backToReadStoryLabel =>
      _uiText(en: 'Back to Read Story Again', fil: 'Bumalik sa Pagbasa');

  String get _continueReadingLabel =>
      _uiText(en: 'Continue Reading ✨', fil: 'Magpatuloy sa Pagbasa ✨');

  String get _synopsisLabel => _uiText(en: 'Synopsis', fil: 'Buod');

  String get _headsUpLabel => _uiText(en: 'Heads Up', fil: 'Paalala');

  String get _sourceReferenceLabel =>
      _uiText(en: 'Source / Reference', fil: 'Pinagmulan / Sanggunian');

  static const List<String> _openingSynopsisSectionLabels = [
    'Synopsis',
    'Buod',
  ];

  static const List<String> _openingSourceSectionLabels = [
    'Source / Reference',
    'Source / Sanggunian',
    'Pinagmulan / Sanggunian',
    'Source and Reference',
    'Reference / Source',
    'Pinagmulan at Sanggunian',
    'Source',
    'Reference',
    'Pinagmulan',
    'Sanggunian',
  ];

  static const List<String> _openingHeadsUpSectionLabels = [
    'Heads Up',
    'Paalala',
    'Reminder',
    'Note',
  ];

  String _hintRemainingText(int remaining) => _uiText(
        en: remaining == 1 || remaining == 0
            ? 'hint remaining'
            : 'hints remaining',
        fil: 'pahiwatig ang natitira',
      );

  String _stripChoicePrefix(String text) {
    return text.replaceFirst(RegExp(r'^\s*[A-Da-d][\.)]\s*'), '');
  }

  String get _showHintsLabel =>
      _uiText(en: 'Show Hints', fil: 'Ipakita ang Mga Pahiwatig');

  String get _usedAllHintsLabel => _uiText(
        en: 'You\'ve used all available hints',
        fil: 'Nagamit mo na ang lahat ng pahiwatig',
      );

  String get _buddyReadyLabel => _uiText(
        en: 'Checkpoint question is ready soon! Continue reading to keep up the flow.',
        fil:
            'Malapit nang lumabas ang checkpoint na tanong! Magpatuloy sa pagbabasa.',
      );

  String get _buddyCheeringLabel =>
      _uiText(en: 'Buddy is cheering you on!', fil: 'Nagmumotivate ang Buddy!');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _stopSpeakingSilently();
      unawaited(_controller?.saveProgress(immediate: true));
      // Best-effort refresh so background/foreground cycles keep the Library in sync.
      unawaited(context.read<AuthService>().refreshCurrentUserFromCloud());
    }
  }

  @override
  void dispose() {
    _wrongAnswerHighlightTimer?.cancel();
    _hintBubbleTimer?.cancel();
    _successBubbleTimer?.cancel();
    final activeAnswerFeedbackStop = _activeAnswerFeedbackStop;
    if (activeAnswerFeedbackStop != null) {
      unawaited(activeAnswerFeedbackStop());
    }
    if (_correctAnswerAudioPool != null || _wrongAnswerAudioPool != null) {
      unawaited(
        Future.wait([
          if (_correctAnswerAudioPool != null)
            _correctAnswerAudioPool!.dispose(),
          if (_wrongAnswerAudioPool != null) _wrongAnswerAudioPool!.dispose(),
        ]),
      );
    }
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
          child: CircularProgressIndicator(color: KuwentoColors.pastelBlue),
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
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        if (didPop) return;
        unawaited(_saveProgressAndExit());
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
                  Expanded(child: _buildStoryContent(context, isDark)),

                  // Navigation controls
                  _buildNavigationControls(context, isDark, ttsService),
                ],
              ),
            ),

            // Floating Buddy at bottom right (thumb zone)
            if (!_showBuddyOverlay && !_showCelebration && !_suppressBuddyHints)
              Positioned(
                right: 16,
                bottom: 140,
                child: BuddyCompanion(
                  state: controller.hasCheckpoint && !controller.isAnswerCorrect
                      ? BuddyState.thinking
                      : BuddyState.idle,
                  size: 60,
                  showSpeechBubble: true,
                  enableTapSpeechBubble: true,
                  tapMessage: _floatingBuddyMessage(controller),
                  speechTitle: _floatingBuddySpeechTitle(controller),
                  onTap: () => _handleFloatingBuddyInteraction(controller),
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
                  _enterFreshSession();
                },
                onActivity: () async {
                  _stopSpeakingSilently();
                  final result = await context.push(
                    '/activity/${_story!.id}?lang=${Uri.encodeComponent(_activeLanguageCode)}',
                  );
                  if (!mounted) return;
                  final action = result is Map ? result['action'] : result;

                  if (action == 'restart') {
                    _enterFreshSession();
                  } else {
                    // User canceled out of activity without navigating, safe to hide celebration now
                    setState(() => _showCelebration = false);
                  }
                },
                onBackToLibrary: _saveProgressAndExit,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    TTSService ttsService,
    bool isFavorite,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Top row with close button and title
          Row(
            children: [
              IconButton(
                onPressed: _saveProgressAndExit,
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
                      _readingNowLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? Colors.white54
                                : KuwentoColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                    ),
                    Text(
                      _displayStoryTitle(),
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
                tooltip: _switchLanguageTooltip,
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
                    '${_localizedPartLabel()} ${_controller!.currentSegmentIndex + 1}',
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
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: KuwentoColors.buddyHappy),
                        ),
                      ],
                    ),
                  Text(
                    '${_controller!.totalSegments} $_sectionCountLabel',
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
                    '$_languageLabel: ${_languageDisplayName(_activeLanguageCode)}',
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

        if (_isOpeningPageSegment(segment, index)) {
          return _buildOpeningPageSegment(
            context,
            segment,
            isDark,
            displayedSegmentText,
          );
        }

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
                        _translatingLabel,
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

    final card = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
            aspectRatio: 16 / 10,
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
        ),
        const AiGeneratedImageNote(),
      ],
    );

    // Removed the Hero widget wrapper to prevent layout exceptions or
    // delayed unmounting frames when _isExiting forces an abrupt removal.
    return card;
  }

  bool _isOpeningPageSegment(StorySegment segment, int index) {
    return index == 0 && segment.id.endsWith('-opening');
  }

  Widget _buildOpeningPageSegment(
    BuildContext context,
    StorySegment segment,
    bool isDark,
    String? displayedSegmentText,
  ) {
    final theme = Theme.of(context);
    final sourceArticleText = segment.content;
    final localizedStoryTitle = _story?.explicitTitleTranslation(
      _activeLanguageCode,
    );
    final title = localizedStoryTitle?.trim().isNotEmpty == true
        ? localizedStoryTitle!
        : (_story?.title ?? '');
    final extractedTitle = _extractOpeningFieldAny(sourceArticleText, const [
      'Title',
      'Pamagat',
    ]);
    final titleValue = _activeLanguageCode == _sourceLanguageCode
        ? (extractedTitle.isNotEmpty ? extractedTitle : title)
        : _displayStoryTitle();
    final genreValue = _extractOpeningFieldAny(sourceArticleText, const [
      'Genre',
      'Uri',
    ]);
    final levelValue = _extractOpeningFieldAny(sourceArticleText, const [
      'Level',
      'Antas',
    ]);
    final languageValue = _extractOpeningFieldAny(sourceArticleText, const [
      'Language',
      'Wika',
    ]);
    final synopsisValue = _displayOpeningText(
      _extractOpeningBlockAny(
        sourceArticleText,
        _openingSynopsisSectionLabels,
        [..._openingSourceSectionLabels, ..._openingHeadsUpSectionLabels],
      ),
    );
    final sourceValue = _displayOpeningText(
      _extractOpeningBlockAny(
        sourceArticleText,
        _openingSourceSectionLabels,
        _openingHeadsUpSectionLabels,
      ),
    );
    final headsUpValue = _displayOpeningText(
      _extractOpeningBlockAny(
        sourceArticleText,
        _openingHeadsUpSectionLabels,
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: isDark ? KuwentoColors.backgroundDark : const Color(0xFFF7FAFC),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          150,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOpeningHeroCard(
                  context,
                  isDark: isDark,
                  title: titleValue,
                  genre: genreValue,
                  level: levelValue,
                  language: languageValue,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 18,
                      color: KuwentoColors.pastelBlueDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _openingPageCaption,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.5,
                          color: isDark
                              ? Colors.white70
                              : KuwentoColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildOpeningGlassCard(
                  context,
                  label: _synopsisLabel,
                  icon: Icons.menu_book_outlined,
                  content: synopsisValue,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildOpeningTipCard(
                  context,
                  label: _headsUpLabel,
                  icon: Icons.push_pin_rounded,
                  content: headsUpValue,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildOpeningReferenceCard(
                  context,
                  isDark: isDark,
                  sourceText: sourceValue,
                ),
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: _controller!.canGoNext
                        ? () {
                            _controller!.goToNext();
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _openingPageButtonLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KuwentoColors.pastelBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: 14,
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 6,
                      shadowColor: KuwentoColors.pastelBlue.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
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

  String get _openingPageButtonLabel =>
      _activeLanguageCode == 'fil' ? 'Susunod' : 'Next';

  String get _openingPageCaption {
    final targetLanguageCode = _activeLanguageCode == _sourceLanguageCode
        ? _targetLanguageCode
        : _sourceLanguageCode;
    final targetLanguageName = _languageDisplayName(targetLanguageCode);

    return _uiText(
      en: _activeLanguageCode == _sourceLanguageCode
          ? 'Use the translate button above to switch to $targetLanguageName.'
          : 'Use the translate button above to switch back to $targetLanguageName.',
      fil: _activeLanguageCode == _sourceLanguageCode
          ? 'Gamitin ang translate button sa itaas para lumipat sa $targetLanguageName.'
          : 'Gamitin ang translate button sa itaas para bumalik sa $targetLanguageName.',
    );
  }

  Widget _buildOpeningHeroCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String genre,
    required String level,
    required String language,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? KuwentoColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : KuwentoColors.creamDark,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: AspectRatio(
              aspectRatio: 16 / 10.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: isDark
                        ? KuwentoColors.backgroundDark
                        : KuwentoColors.cream,
                  ),
                  Image.asset(
                    _story!.coverImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            KuwentoColors.pastelBlue.withValues(alpha: 0.2),
                            KuwentoColors.skyBlue.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 72,
                          color: KuwentoColors.pastelBlueDark,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.04),
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        stops: const [0.0, 0.58, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.md,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildOpeningHeroBadge(
                              context,
                              label: genre,
                              isDark: true,
                              accent: KuwentoColors.pastelBlue,
                            ),
                            _buildOpeningHeroBadge(
                              context,
                              label: level,
                              isDark: true,
                              accent: KuwentoColors.softCoral,
                            ),
                            _buildOpeningHeroBadge(
                              context,
                              label: language,
                              isDark: true,
                              accent: KuwentoColors.buddyThinking,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const AiGeneratedImageNote(),
      ],
    );
  }

  Widget _buildOpeningHeroBadge(
    BuildContext context, {
    required String label,
    required bool isDark,
    Color? accent,
  }) {
    final tint = accent ?? KuwentoColors.pastelBlue;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? tint.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : tint.withValues(alpha: 0.18),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpeningGlassCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String content,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : KuwentoColors.pastelBlue.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: KuwentoColors.pastelBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: KuwentoColors.pastelBlueDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : KuwentoColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                content,
                style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: FontSizes.bodyLarge + 1,
                      height: 1.8,
                      color: isDark ? Colors.white : KuwentoColors.textPrimary,
                    ) ??
                    TextStyle(
                      fontSize: FontSizes.bodyLarge + 1,
                      height: 1.8,
                      color: isDark ? Colors.white : KuwentoColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpeningTipCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String content,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: KuwentoColors.softCoral.withValues(alpha: isDark ? 0.12 : 0.14),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: KuwentoColors.softCoral.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: KuwentoColors.coralDark),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: KuwentoColors.coralDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                ) ??
                TextStyle(
                  height: 1.8,
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningReferenceCard(
    BuildContext context, {
    required bool isDark,
    required String sourceText,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : KuwentoColors.creamDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.source_outlined,
                size: 18,
                color: KuwentoColors.pastelBlueDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _sourceReferenceLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : KuwentoColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sourceText,
            style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: isDark ? Colors.white70 : KuwentoColors.textSecondary,
                ) ??
                TextStyle(
                  height: 1.65,
                  color: isDark ? Colors.white70 : KuwentoColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  String _extractOpeningFieldAny(String content, List<String> labels) {
    for (final label in labels) {
      final match = RegExp(
        '^${RegExp.escape(label)}:\\s*(.+)'
        r'$',
        multiLine: true,
      ).firstMatch(content);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  String _extractOpeningBlockAny(
    String content,
    List<String> startLabels, [
    List<String>? endLabels,
  ]) {
    final startPattern = _openingSectionPattern(startLabels);
    RegExpMatch? startMatch;
    startMatch = startPattern.firstMatch(content);

    if (startMatch == null) return '';

    final startIndex = startMatch.end;
    if (endLabels == null) {
      return content.substring(startIndex).trim();
    }

    final trailingContent = content.substring(startIndex);
    int? endIndex;
    final endPattern = _openingSectionPattern(endLabels);
    for (final match in endPattern.allMatches(trailingContent)) {
      endIndex =
          endIndex == null || match.start < endIndex ? match.start : endIndex;
    }

    return content
        .substring(
          startIndex,
          endIndex == null ? content.length : startIndex + endIndex,
        )
        .trim();
  }

  RegExp _openingSectionPattern(List<String> labels) {
    final pattern = labels
        .map(
          (label) => RegExp.escape(label)
              .replaceAll(r'\ ', r'\s+')
              .replaceAll(r'\/', r'\s*\/\s*'),
        )
        .join('|');

    return RegExp(
      '^\\s*(?:$pattern)\\s*:\\s*',
      multiLine: true,
      caseSensitive: false,
    );
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -6),
              child: SizedBox(
                width: 52,
                height: 52,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: true),
                  child: const Center(
                    child: BuddyCompanion(
                      state: BuddyState.thinking,
                      size: 40,
                      showSpeechBubble: false,
                      disableHighlightEffects: true,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _readingCheckpointTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: KuwentoColors.pastelBlue,
                        ),
                  ),
                  Text(
                    _readingCheckpointSubtitle,
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
    BuildContext context,
    bool isDark,
    TTSService ttsService,
  ) {
    final isCompleted = _controller!.isCompleted;
    final isNarrationPaused = ttsService.isPaused;
    final isNarrationPlaying =
        !isNarrationPaused && (_isNarrationPlaying || ttsService.isSpeaking);
    final isVoiceEnabled = ttsService.isTtsEnabled;
    final isOpeningPage = _isOpeningPageSegment(
      _controller!.currentSegment,
      _controller!.currentSegmentIndex,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? KuwentoColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
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
            onPressed: isVoiceEnabled ? _toggleNarrationPlayback : null,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                !isVoiceEnabled
                    ? Icons.volume_off_rounded
                    : isNarrationPaused
                        ? Icons.play_circle
                        : isNarrationPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                key: ValueKey<bool>(isNarrationPlaying),
                size: 40,
                color: isVoiceEnabled
                    ? KuwentoColors.pastelBlue
                    : KuwentoColors.textMuted,
              ),
            ),
          ),

          if (!isOpeningPage)
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
            onPressed: (_controller!.canGoNext && !_controller!.hasCheckpoint)
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

  void _handleFloatingBuddyInteraction(StoryController controller) {
    // Intentionally left blank: tapping Buddy no longer shows a tooltip message.
  }

  String _floatingBuddyMessage(StoryController controller) {
    if (controller.hasCheckpoint && !controller.isAnswerCorrect) {
      return _buddyReadyLabel;
    }

    return _buddyCheeringLabel;
  }

  String? _buddySpeechTitleForState(BuddyState state) {
    switch (state) {
      case BuddyState.idle:
        return _uiText(en: 'Buddy Tip', fil: 'Tip ni Buddy');
      case BuddyState.thinking:
        return _uiText(en: 'Thinking Together', fil: 'Mag-isip Tayo');
      case BuddyState.happy:
        return _uiText(en: 'Nice Work', fil: 'Magaling');
      case BuddyState.encouraging:
        return _uiText(en: 'Keep Going', fil: 'Tuloy Lang');
      case BuddyState.sympathetic:
        return _uiText(en: 'Take Your Time', fil: 'Dahan-dahan Lang');
      case BuddyState.waving:
        return _uiText(en: 'Hello', fil: 'Kumusta');
      case BuddyState.cheering:
        return _uiText(en: 'Celebrate', fil: 'Ipagdiwang Natin');
      default:
        return null;
    }
  }

  String? _floatingBuddySpeechTitle(StoryController controller) {
    final state = controller.hasCheckpoint && !controller.isAnswerCorrect
        ? BuddyState.thinking
        : BuddyState.idle;
    return _buddySpeechTitleForState(state);
  }

  void _startSuccessBubble() {
    if (_showQuestionSuccessBubble) return;
    _successBubbleTimer?.cancel();
    setState(() => _showQuestionSuccessBubble = true);
    _successBubbleTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _showQuestionSuccessBubble = false);
    });
  }

  void _hideSuccessBubble() {
    if (!_showQuestionSuccessBubble) return;
    _successBubbleTimer?.cancel();
    setState(() => _showQuestionSuccessBubble = false);
  }

  void _startHintBubble() {
    _hintBubbleTimer?.cancel();
    setState(() {
      _showQuestionHintBubble = true;
      _hintBubblePresentationId++;
    });
    _hintBubbleTimer = Timer(_hintBubbleDuration, () {
      if (!mounted) return;
      setState(() => _showQuestionHintBubble = false);
    });
  }

  void _hideHintBubble() {
    if (!_showQuestionHintBubble) return;
    _hintBubbleTimer?.cancel();
    setState(() => _showQuestionHintBubble = false);
  }

  Widget _buildBuddyOverlay(BuildContext context, bool isDark) {
    final question = _controller!.currentQuestion;
    if (question == null) return const SizedBox.shrink();
    final hintButtonMaxWidth = _activeLanguageCode == 'fil' ? 320.0 : 220.0;

    final displaySkill = _skillLabel(question.skill);
    final displayQuestion = _translatedQuestionText(question.question);
    final optionOrder = _controller!.optionOrder;
    final displayOptions = optionOrder
        .map(
          (optionIndex) => _stripChoicePrefix(
            _translatedQuestionText(question.options[optionIndex]),
          ),
        )
        .toList(growable: false);
    final displayHint = _translatedQuestionText(question.hint);
    final displayEncouragement = _translatedQuestionText(
      question.encouragement,
    );

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) =>
                Transform.scale(scale: _overlayAnimation.value, child: child),
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Skill badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: KuwentoColors.pastelBlue.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Text(
                            displaySkill,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
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
                            color:
                                isDark ? KuwentoColors.cardDark : Colors.white,
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
                                optionOrder.length,
                                (visibleIndex) => _buildAnswerOption(
                                  context,
                                  isDark,
                                  visibleIndex,
                                  optionOrder[visibleIndex],
                                  displayOptions[visibleIndex],
                                  question,
                                ),
                              ),

                              // Hint/back controls (when the answer is not yet correct)
                              if (!_controller!.isAnswerCorrect) ...[
                                const SizedBox(height: AppSpacing.md),
                                Align(
                                  alignment: Alignment.center,
                                  child: Opacity(
                                    opacity: _controller!.hasHintAttemptsLeft
                                        ? 1.0
                                        : 0.5,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: hintButtonMaxWidth,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton(
                                          onPressed:
                                              _controller!.hasHintAttemptsLeft
                                                  ? _handleShowHintsTap
                                                  : null,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: KuwentoColors.pastelBlue,
                                              width: 2,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 18,
                                            ),
                                            alignment: Alignment.center,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  const SizedBox(
                                                    width: 22,
                                                    child: Center(
                                                      child: Text(
                                                        '💡',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            _showHintsLabel,
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1,
                                                            softWrap: false,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            style:
                                                                const TextStyle(
                                                              color: KuwentoColors
                                                                  .pastelBlue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    '${_controller!.remainingHintAttempts}',
                                                                style: Theme.of(
                                                                  context,
                                                                )
                                                                    .textTheme
                                                                    .labelMedium
                                                                    ?.copyWith(
                                                                      color: KuwentoColors
                                                                          .coralDark,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ),
                                                              ),
                                                              TextSpan(
                                                                text: ' ',
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    _hintRemainingText(
                                                                  _controller!
                                                                      .remainingHintAttempts,
                                                                ),
                                                                style: Theme.of(
                                                                  context,
                                                                )
                                                                    .textTheme
                                                                    .labelMedium
                                                                    ?.copyWith(
                                                                      color: KuwentoColors
                                                                          .coralDark,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                                      _backToReadStoryLabel,
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
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                          _controller!.continueAfterCorrect();
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: KuwentoColors.buddyHappy,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: Text(
                                      _continueReadingLabel,
                                      style: const TextStyle(
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
                if (_controller!.showHint &&
                    !_controller!.isAnswerCorrect &&
                    _showQuestionHintBubble)
                  Positioned(
                    right: 16,
                    bottom: 100,
                    child: BuddyCompanion(
                      state: _controller!.showHint
                          ? BuddyState.sympathetic
                          : BuddyState.thinking,
                      message: displayHint,
                      size:
                          MediaQuery.of(context).size.width < 360 ? 50.0 : 54.0,
                      showSpeechBubble: true,
                      enableTapSpeechBubble: false,
                      speechTitle:
                          _buddySpeechTitleForState(BuddyState.sympathetic),
                      speechBubbleCountdownDuration: _hintBubbleDuration,
                      speechBubbleInstanceId: _hintBubblePresentationId,
                    ),
                  ),
                if (_controller!.isAnswerCorrect && _showQuestionSuccessBubble)
                  Positioned(
                    right: 16,
                    bottom: 100,
                    child: BuddyCompanion(
                      state: BuddyState.happy,
                      message: displayEncouragement,
                      size:
                          MediaQuery.of(context).size.width < 360 ? 50.0 : 54.0,
                      showSpeechBubble: true,
                      enableTapSpeechBubble: false,
                      speechTitle: _buddySpeechTitleForState(BuddyState.happy),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
    BuildContext context,
    bool isDark,
    int visibleIndex,
    int optionIndex,
    String option,
    QuestionModel question,
  ) {
    final isSelected = _controller!.selectedAnswerIndex == optionIndex;
    final isCorrect = question.isCorrect(optionIndex);
    final isTemporarilyWrong = _recentWrongAnswerIndex == optionIndex;
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
                final isCorrectSelection = question.isCorrect(optionIndex);
                unawaited(
                  _playAnswerFeedbackSound(isCorrect: isCorrectSelection),
                );
                _controller!.submitAnswer(optionIndex);
                if (!isCorrectSelection) {
                  _wrongAnswerHighlightTimer?.cancel();
                  setState(() => _recentWrongAnswerIndex = optionIndex);
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
                          String.fromCharCode(65 + visibleIndex),
                          textAlign: TextAlign.center,
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
