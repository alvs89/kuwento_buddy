import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/question_model.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Story session state for tracking progress
enum SessionState { reading, questioning, completed }

/// Controller for managing story reading session
/// Implements the "Read-Think-Continue" logic with progress persistence
class StoryController extends ChangeNotifier {
  final StoryModel story;
  final bool resumeProgress;
  final AuthService _authService = AuthService();
  final ToastService _toastService = ToastService();

  // Current segment index
  int _currentSegmentIndex = 0;

  // Highest unlocked segment (navigation lock)
  int _unlockedSegmentIndex = 0;

  // Current session state
  SessionState _sessionState = SessionState.reading;

  // Question attempt tracking
  int _currentAttempts = 0;
  bool _showHint = false;
  int? _selectedAnswerIndex;
  bool _isAnswerCorrect = false;
  int _hintAttemptsUsed = 0;
  static const int _maxHintAttempts = 3;
  static const String _hintUsagePrefsKey = 'story_hint_usage';

  // Track wrong answers to allow retry (don't lock out options)
  Set<int> _wrongAnswers = {};

  // Session statistics
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  final Map<String, int> _skillCorrect = {};
  final Map<String, int> _skillTotal = {};
  int _starsEarned = 0;
  bool _replayMode = false;

  // Track if question was answered correctly on first try
  bool _answeredFirstTry = true;
  Future<void> _saveQueue = Future.value();

  StoryController({required this.story, this.resumeProgress = false}) {
    if (resumeProgress) {
      _loadProgress();
    } else {
      _ensureProgressEntry(immediate: true);
    }
  }

  // Getters
  int get currentSegmentIndex => _currentSegmentIndex;
  int get unlockedSegmentIndex => _unlockedSegmentIndex;
  int get totalSegments => story.segments.length;
  SessionState get sessionState => _sessionState;
  int get currentAttempts => _currentAttempts;
  bool get showHint => _showHint;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get isAnswerCorrect => _isAnswerCorrect;
  int get remainingHintAttempts => _maxHintAttempts - _hintAttemptsUsed;
  bool get hasHintAttemptsLeft => remainingHintAttempts > 0;
  int get correctAnswers => _correctAnswers;
  int get totalQuestions => _totalQuestions;
  int get starsEarned => _starsEarned;
  Set<int> get wrongAnswers => _wrongAnswers;
  bool get isReplayMode => _replayMode;

  /// Current segment
  StorySegment get currentSegment => story.segments[_currentSegmentIndex];

  /// Current question (if any)
  QuestionModel? get currentQuestion => currentSegment.question;

  /// Progress as percentage (0.0 to 1.0)
  double get progress => (_currentSegmentIndex + 1) / totalSegments;

  /// Check if current segment has a question checkpoint
  bool get hasCheckpoint => currentQuestion != null;

  /// Check if we can navigate to next segment
  bool get canGoNext =>
      _currentSegmentIndex < _unlockedSegmentIndex ||
      (_currentSegmentIndex == _unlockedSegmentIndex &&
          (_sessionState == SessionState.reading && !hasCheckpoint ||
              _isAnswerCorrect));

  /// Check if we can navigate to previous segment
  bool get canGoPrevious => _currentSegmentIndex > 0;

  /// Check if story is completed
  bool get isCompleted => _sessionState == SessionState.completed;

  /// Comprehension score as percentage
  double get comprehensionScore =>
      _totalQuestions > 0 ? (_correctAnswers / _totalQuestions) * 100 : 0;

  /// Get skill mastery for a specific skill
  double getSkillMastery(QuestionSkill skill) {
    final skillName = skill.name;
    final total = _skillTotal[skillName] ?? 0;
    final correct = _skillCorrect[skillName] ?? 0;
    return total > 0 ? (correct / total) * 100 : 0;
  }

  /// Load saved progress
  Future<void> _loadProgress() async {
    try {
      final user = await _waitForHydratedUser();
      if (user == null) return;

      final progress = user.storyProgress[story.id];
      if (progress != null) {
        _currentSegmentIndex = progress.currentSegmentIndex;
        _unlockedSegmentIndex = progress.currentSegmentIndex;
        _correctAnswers = progress.correctAnswers;
        _totalQuestions = progress.totalQuestions;
        _skillCorrect.addAll(progress.skillCorrect);
        _skillTotal.addAll(progress.skillTotal);
        _sessionState = progress.isCompleted
            ? SessionState.completed
            : SessionState.reading;
        final persisted = await _loadPersistedHintAttempts();
        final remoteHintAttempts = progress.hintAttemptsUsed;
        _hintAttemptsUsed = math.min(
          _maxHintAttempts,
          math.max(remoteHintAttempts, persisted),
        );
        notifyListeners();
      } else {
        final persisted = await _loadPersistedHintAttempts();
        if (persisted > 0) {
          _hintAttemptsUsed = math.min(_maxHintAttempts, persisted);
          notifyListeners();
        }
      }
      // Create an entry immediately so "In Progress" shows up as soon as opened.
    } catch (e) {
      debugPrint('Error loading progress: $e');
    } finally {
      _ensureProgressEntry(immediate: true);
    }
  }

  Future<UserModel?> _waitForHydratedUser() async {
    // Auth state can still be hydrating when a story opens; retry briefly.
    for (var attempt = 0; attempt < 8; attempt++) {
      final current = _authService.currentUser;
      if (current != null) return current;
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return _authService.currentUser;
  }

  void _ensureProgressEntry({bool immediate = false}) {
    if (_sessionState == SessionState.completed) return;
    _saveProgress(immediate: immediate);
  }

  static Future<Map<String, int>> _readHintUsageMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_hintUsagePrefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) {
          final attempt = value is num ? value.toInt() : 0;
          return MapEntry(key, attempt);
        });
      }
    } catch (e) {
      debugPrint('Failed to decode hint usage map: $e');
    }
    return {};
  }

  static Future<void> _writeHintUsageMap(Map<String, int> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hintUsagePrefsKey, jsonEncode(map));
  }

  Future<int> _loadPersistedHintAttempts() async {
    final map = await _readHintUsageMap();
    return map[story.id] ?? 0;
  }

  Future<void> _persistHintAttempts() async {
    if (_replayMode) return;
    try {
      final map = await _readHintUsageMap();
      if (_hintAttemptsUsed <= 0) {
        if (map.remove(story.id) != null) {
          await _writeHintUsageMap(map);
        }
        return;
      }
      map[story.id] = _hintAttemptsUsed;
      await _writeHintUsageMap(map);
    } catch (e) {
      debugPrint('Failed to persist hint attempts: $e');
    }
  }

  Future<void> _clearPersistedHintAttempts() async {
    try {
      final map = await _readHintUsageMap();
      if (map.remove(story.id) != null) {
        await _writeHintUsageMap(map);
      }
    } catch (e) {
      debugPrint('Failed to clear hint attempts: $e');
    }
  }

  /// Save current progress
  void _saveProgress({bool immediate = false}) {
    if (_replayMode) return; // do not persist progress in replay mode
    if (immediate) {
      _saveQueue = _saveProgressInternal();
      return;
    }
    _saveQueue = _saveQueue.then((_) => _saveProgressInternal());
  }

  /// Flush any queued progress write before leaving the story screen.
  Future<void> saveProgress({bool immediate = false}) async {
    _saveProgress(immediate: immediate);
    await _saveQueue;
  }

  Future<void> _saveProgressInternal() async {
    if (_replayMode) return;
    debugPrint(
        'StoryController(${story.id}): Saving progress - segment=$_currentSegmentIndex, state=$_sessionState, uid=${_authService.currentUser?.id ?? "null"}');
    try {
      final userSnapshot =
          _authService.currentUser ?? await _waitForHydratedUser();
      final existingProgress = userSnapshot?.storyProgress[story.id];
      final isNowCompleted = _sessionState == SessionState.completed;
      final wasAlreadyCompleted = existingProgress?.isCompleted == true;
      final hadCompletedVariant = !isNowCompleted &&
          (userSnapshot?.storyProgress.values.any(
                (entry) =>
                    entry.isCompleted &&
                    _normalizeStoryKey(entry.storyId) ==
                        _normalizeStoryKey(story.id),
              ) ??
              false);

      final progress = StoryProgress(
        storyId: story.id,
        storyTitle: story.title,
        currentSegmentIndex: _currentSegmentIndex,
        totalSegments: totalSegments,
        isCompleted: _sessionState == SessionState.completed,
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        starsEarned: _starsEarned,
        skillCorrect: Map.from(_skillCorrect),
        skillTotal: Map.from(_skillTotal),
        startedAt: existingProgress?.startedAt ?? DateTime.now(),
        completedAt: isNowCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
        hintAttemptsUsed: _hintAttemptsUsed,
      );

      // FIXED logging: approximate key (title.trim())
      final storyKey = story.title.trim();
      debugPrint(
          'StoryController(${story.id}): WILL SAVE to Firestore key="$storyKey" (appStoryId=${story.id})');

      await _authService.saveStoryProgress(
        progress,
        starsDelta: isNowCompleted && !wasAlreadyCompleted ? _starsEarned : 0,
        completedIncrement: isNowCompleted && !wasAlreadyCompleted,
        clearCompletedVariants:
            !isNowCompleted && (wasAlreadyCompleted || hadCompletedVariant),
      );
    } catch (e) {
      debugPrint('StoryController(${story.id}): Error saving progress: $e');
    }
  }

  String _normalizeStoryKey(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

  /// Navigate to next segment
  void goToNext() {
    if (!canGoNext) return;

    if (_currentSegmentIndex < totalSegments - 1) {
      _currentSegmentIndex++;
      if (_currentSegmentIndex > _unlockedSegmentIndex) {
        _unlockedSegmentIndex = _currentSegmentIndex;
      }
      _resetQuestionState();
      _sessionState = SessionState.reading;
      _saveProgress();
    } else {
      _completeStory();
    }
    notifyListeners();
  }

  /// Navigate to previous segment
  void goToPrevious() {
    if (!canGoPrevious) return;

    _currentSegmentIndex--;
    _resetQuestionState();
    _sessionState = SessionState.reading;
    notifyListeners();
  }

  /// Jump to specific segment (only if unlocked)
  void goToSegment(int index) {
    if (index < 0 || index > _unlockedSegmentIndex) return;

    _currentSegmentIndex = index;
    _resetQuestionState();
    _sessionState = SessionState.reading;
    notifyListeners();
  }

  /// Reveal the hint proactively without waiting for a wrong attempt.
  void revealHint() {
    if (currentQuestion == null || _showHint || !hasHintAttemptsLeft) return;

    _showHint = true;
    notifyListeners();
  }

  /// Request a hint, tracking per-question attempt limits.
  HintRequestResult requestHint() {
    if (currentQuestion == null) {
      return HintRequestResult(
        hintShown: false,
        remainingAttempts: remainingHintAttempts,
        alreadyExhausted: remainingHintAttempts <= 0,
      );
    }

    if (_replayMode) {
      _showHint = true;
      notifyListeners();
      return HintRequestResult(
        hintShown: true,
        remainingAttempts: remainingHintAttempts,
        alreadyExhausted: false,
      );
    }

    if (!hasHintAttemptsLeft) {
      // Exhausted: do not show hint; keep Buddy hidden until story is re-completed.
      _showHint = false;
      notifyListeners();
      return HintRequestResult(
        hintShown: false,
        remainingAttempts: 0,
        alreadyExhausted: true,
      );
    }

    _hintAttemptsUsed++;
    _showHint = true;
    notifyListeners();
    unawaited(_persistHintAttempts());
    _saveProgress();

    final remaining = remainingHintAttempts;
    return HintRequestResult(
      hintShown: true,
      remainingAttempts: remaining,
      alreadyExhausted: remaining == 0,
    );
  }

  /// Trigger the question checkpoint
  void triggerCheckpoint() {
    if (!hasCheckpoint) return;

    _sessionState = SessionState.questioning;
    notifyListeners();
  }

  /// Go back to reading from question (to re-read the story)
  void goBackToReading() {
    _showHint = false;
    _sessionState = SessionState.reading;
    notifyListeners();
  }

  /// Submit answer to current question
  /// Returns true if correct, false if wrong
  /// Does NOT reveal correct answer on wrong selection - allows retry
  void submitAnswer(int answerIndex) {
    if (currentQuestion == null) return;

    _selectedAnswerIndex = answerIndex;
    _currentAttempts++;
    _isAnswerCorrect = currentQuestion!.isCorrect(answerIndex);

    // Count this question toward totals on the first attempt, regardless of correctness.
    if (_currentAttempts == 1) {
      final skillName = currentQuestion!.skill.name;
      _skillTotal[skillName] = (_skillTotal[skillName] ?? 0) + 1;
      _totalQuestions++;
    }

    if (_isAnswerCorrect) {
      // Correct answer!
      final skillName = currentQuestion!.skill.name;

      // Only count as correct in stats if answered on first try
      if (_answeredFirstTry) {
        _correctAnswers++;
        _skillCorrect[skillName] = (_skillCorrect[skillName] ?? 0) + 1;
      }
      _toastService.showCorrectAnswer();
    } else {
      // Wrong answer - track it but allow retry
      _answeredFirstTry = false;

      // Auto-show Buddy only after the learner has used all allowed answer attempts.
      const int attemptsBeforeHint = 3;
      if (_currentAttempts >= attemptsBeforeHint && hasHintAttemptsLeft) {
        _showHint = true;
      } else if (!hasHintAttemptsLeft) {
        _showHint = false;
      }

      // Clear selected answer to allow retry
      _selectedAnswerIndex = null;
    }

    notifyListeners();
  }

  /// Continue after correct answer
  void continueAfterCorrect() {
    if (!_isAnswerCorrect) return;

    if (_currentSegmentIndex < totalSegments - 1) {
      goToNext();
    } else {
      _completeStory();
      notifyListeners();
    }
  }

  /// Complete the story
  void _completeStory() {
    _sessionState = SessionState.completed;

    // Calculate stars based on comprehension score
    final score = comprehensionScore;
    if (score >= 90) {
      _starsEarned = 3;
    } else if (score >= 70) {
      _starsEarned = 2;
    } else if (score >= 50) {
      _starsEarned = 1;
    } else {
      _starsEarned = 0;
    }

    if (_replayMode) {
      notifyListeners();
      return;
    }

    _saveProgress();
    unawaited(_clearPersistedHintAttempts());
    _toastService.showStoryCompleted(_starsEarned);
  }

  /// Reset question state for new segment
  void _resetQuestionState() {
    _currentAttempts = 0;
    _showHint = false;
    _selectedAnswerIndex = null;
    _isAnswerCorrect = false;
    _wrongAnswers = {};
    _answeredFirstTry = true;
  }

  /// Reset entire session
  void resetSession() {
    _currentSegmentIndex = 0;
    _unlockedSegmentIndex = 0;
    _sessionState = SessionState.reading;
    _replayMode = false;
    _correctAnswers = 0;
    _totalQuestions = 0;
    _skillCorrect.clear();
    _skillTotal.clear();
    _starsEarned = 0;
    _hintAttemptsUsed = 0;
    _resetQuestionState();
    notifyListeners();
    unawaited(_clearPersistedHintAttempts());
    _ensureProgressEntry();
  }

  /// Start a replay session where progress is not recorded.
  void startReplayMode() {
    _replayMode = true;
    _currentSegmentIndex = 0;
    _unlockedSegmentIndex = 0;
    _sessionState = SessionState.reading;
    // Fresh local scoring for this replay run (not persisted)
    _correctAnswers = 0;
    _totalQuestions = 0;
    _skillCorrect.clear();
    _skillTotal.clear();
    _starsEarned = 0;
    _hintAttemptsUsed = 0;
    _resetQuestionState();
    notifyListeners();
  }

  /// Exit replay mode and prepare for a fresh counted session.
  void startFreshCountedSession() {
    _replayMode = false;
    resetSession();
  }

  /// Mark segment as read and trigger checkpoint if needed
  void markCurrentSegmentRead() {
    if (hasCheckpoint && !_isAnswerCorrect) {
      triggerCheckpoint();
    }
  }
}

/// Result of a hint request, letting callers manage messaging and limits.
class HintRequestResult {
  final bool hintShown;
  final int remainingAttempts;
  final bool alreadyExhausted;

  HintRequestResult({
    required this.hintShown,
    required this.remainingAttempts,
    required this.alreadyExhausted,
  });
}
