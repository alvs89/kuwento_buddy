import 'package:flutter/foundation.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/models/question_model.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/auth_service.dart';
import 'package:kuwentobuddy/services/toast_service.dart';

/// Story session state for tracking progress
enum SessionState { reading, questioning, completed }

/// Controller for managing story reading session
/// Implements the "Read-Think-Continue" logic with progress persistence
class StoryController extends ChangeNotifier {
  final StoryModel story;
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

  // Track wrong answers to allow retry (don't lock out options)
  Set<int> _wrongAnswers = {};

  // Session statistics
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  final Map<String, int> _skillCorrect = {};
  final Map<String, int> _skillTotal = {};
  int _starsEarned = 0;

  // Track if question was answered correctly on first try
  bool _answeredFirstTry = true;

  StoryController({required this.story}) {
    _loadProgress();
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
  int get correctAnswers => _correctAnswers;
  int get totalQuestions => _totalQuestions;
  int get starsEarned => _starsEarned;
  Set<int> get wrongAnswers => _wrongAnswers;

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
      if (progress != null && !progress.isCompleted) {
        _currentSegmentIndex = progress.currentSegmentIndex;
        _unlockedSegmentIndex = progress.currentSegmentIndex;
        _correctAnswers = progress.correctAnswers;
        _totalQuestions = progress.totalQuestions;
        _skillCorrect.addAll(progress.skillCorrect);
        _skillTotal.addAll(progress.skillTotal);
        notifyListeners();
      } else if (progress == null) {
        // Seed first-open progress so Firestore reflects started stories.
        await _saveProgress();
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
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

  /// Save current progress
  Future<void> _saveProgress() async {
    try {
      final userSnapshot =
          _authService.currentUser ?? await _waitForHydratedUser();
      if (userSnapshot == null) return;

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
        startedAt:
            userSnapshot.storyProgress[story.id]?.startedAt ?? DateTime.now(),
        completedAt:
            _sessionState == SessionState.completed ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      // Merge with the latest user state to avoid clobbering fields like favorites.
      final latestUser = _authService.currentUser;
      if (latestUser == null) return;

      final updatedProgress =
          Map<String, StoryProgress>.from(latestUser.storyProgress);
      updatedProgress[story.id] = progress;

      final updatedUser = latestUser.copyWith(
        storyProgress: updatedProgress,
        totalStars: _sessionState == SessionState.completed
            ? latestUser.totalStars + _starsEarned
            : latestUser.totalStars,
        storiesCompleted: _sessionState == SessionState.completed &&
                latestUser.storyProgress[story.id]?.isCompleted != true
            ? latestUser.storiesCompleted + 1
            : latestUser.storiesCompleted,
        updatedAt: DateTime.now(),
      );

      await _authService.updateUser(updatedUser);
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

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

  /// Trigger the question checkpoint
  void triggerCheckpoint() {
    if (!hasCheckpoint) return;

    _sessionState = SessionState.questioning;
    notifyListeners();
  }

  /// Go back to reading from question (to re-read the story)
  void goBackToReading() {
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

    if (_isAnswerCorrect) {
      // Correct answer!
      final skillName = currentQuestion!.skill.name;
      _skillTotal[skillName] = (_skillTotal[skillName] ?? 0) + 1;

      // Only count as correct in stats if answered on first try
      if (_answeredFirstTry) {
        _correctAnswers++;
        _skillCorrect[skillName] = (_skillCorrect[skillName] ?? 0) + 1;
      }
      _totalQuestions++;
      _toastService.showCorrectAnswer();
    } else {
      // Wrong answer - track it but allow retry
      _answeredFirstTry = false;

      // Show hint after first wrong attempt
      if (_currentAttempts >= 1) {
        _showHint = true;
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

    _saveProgress();
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
    _correctAnswers = 0;
    _totalQuestions = 0;
    _skillCorrect.clear();
    _skillTotal.clear();
    _starsEarned = 0;
    _resetQuestionState();
    notifyListeners();
  }

  /// Mark segment as read and trigger checkpoint if needed
  void markCurrentSegmentRead() {
    if (hasCheckpoint && !_isAnswerCorrect) {
      triggerCheckpoint();
    }
  }
}
