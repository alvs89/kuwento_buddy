import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuwentobuddy/models/question_model.dart';

/// User progress for a specific story
class StoryProgress {
  final String storyId;
  final String? storyTitle;
  final int currentSegmentIndex;
  final int totalSegments;
  final bool isCompleted;
  final int correctAnswers;
  final int totalQuestions;
  final int starsEarned;
  final Map<String, int> skillCorrect; // inference, prediction, emotion
  final Map<String, int> skillTotal;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final int hintAttemptsUsed;

  const StoryProgress({
    required this.storyId,
    this.storyTitle,
    this.currentSegmentIndex = 0,
    this.totalSegments = 0,
    this.isCompleted = false,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.starsEarned = 0,
    this.skillCorrect = const {},
    this.skillTotal = const {},
    required this.startedAt,
    this.completedAt,
    required this.updatedAt,
    this.hintAttemptsUsed = 0,
  });

  double get progressPercent =>
      totalSegments > 0
          ? (() {
              final rawPercent = (currentSegmentIndex + 1) / totalSegments;
              if (isCompleted) return 1.0;
              return rawPercent >= 1.0 ? 0.99 : rawPercent;
            })()
          : 0;
  double get comprehensionScore =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  double getSkillMastery(QuestionSkill skill) {
    final skillName = skill.name;
    final total = skillTotal[skillName] ?? 0;
    final correct = skillCorrect[skillName] ?? 0;
    return total > 0 ? (correct / total) * 100 : 0;
  }

  factory StoryProgress.fromJson(Map<String, dynamic> json) => StoryProgress(
        storyId: json['storyId'] as String,
        storyTitle: json['storyTitle'] as String?,
        currentSegmentIndex: json['currentSegmentIndex'] as int? ?? 0,
        totalSegments: json['totalSegments'] as int? ?? 0,
        isCompleted: json['isCompleted'] as bool? ?? false,
        correctAnswers: json['correctAnswers'] as int? ?? 0,
        totalQuestions: json['totalQuestions'] as int? ?? 0,
        starsEarned: json['starsEarned'] as int? ?? 0,
        skillCorrect: Map<String, int>.from(json['skillCorrect'] ?? {}),
        skillTotal: Map<String, int>.from(json['skillTotal'] ?? {}),
        startedAt: _parseDateTime(json['startedAt']),
        completedAt: json['completedAt'] != null
            ? _parseDateTime(json['completedAt'])
            : null,
        updatedAt: _parseDateTime(json['updatedAt']),
        hintAttemptsUsed: (json['hintAttemptsUsed'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'storyId': storyId,
        'storyTitle': storyTitle,
        'currentSegmentIndex': currentSegmentIndex,
        'totalSegments': totalSegments,
        'isCompleted': isCompleted,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'starsEarned': starsEarned,
        'skillCorrect': skillCorrect,
        'skillTotal': skillTotal,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'hintAttemptsUsed': hintAttemptsUsed,
      };

  StoryProgress copyWith({
    String? storyId,
    String? storyTitle,
    int? currentSegmentIndex,
    int? totalSegments,
    bool? isCompleted,
    int? correctAnswers,
    int? totalQuestions,
    int? starsEarned,
    Map<String, int>? skillCorrect,
    Map<String, int>? skillTotal,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    int? hintAttemptsUsed,
  }) =>
      StoryProgress(
        storyId: storyId ?? this.storyId,
        storyTitle: storyTitle ?? this.storyTitle,
        currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
        totalSegments: totalSegments ?? this.totalSegments,
        isCompleted: isCompleted ?? this.isCompleted,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        starsEarned: starsEarned ?? this.starsEarned,
        skillCorrect: skillCorrect ?? this.skillCorrect,
        skillTotal: skillTotal ?? this.skillTotal,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        hintAttemptsUsed: hintAttemptsUsed ?? this.hintAttemptsUsed,
      );
}

DateTime _parseDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

/// User preferences
class UserPreferences {
  final String language; // 'en' or 'fil'
  final double voiceSpeed;
  final bool enableTTS;
  final bool enableAnimations;

  const UserPreferences({
    this.language = 'en',
    this.voiceSpeed = 1.0,
    this.enableTTS = true,
    this.enableAnimations = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        language: json['language'] as String? ?? 'en',
        voiceSpeed: (json['voiceSpeed'] as num?)?.toDouble() ?? 1.0,
        enableTTS: json['enableTTS'] as bool? ?? true,
        enableAnimations: json['enableAnimations'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'language': language,
        'voiceSpeed': voiceSpeed,
        'enableTTS': enableTTS,
        'enableAnimations': enableAnimations,
      };

  UserPreferences copyWith({
    String? language,
    double? voiceSpeed,
    bool? enableTTS,
    bool? enableAnimations,
  }) =>
      UserPreferences(
        language: language ?? this.language,
        voiceSpeed: voiceSpeed ?? this.voiceSpeed,
        enableTTS: enableTTS ?? this.enableTTS,
        enableAnimations: enableAnimations ?? this.enableAnimations,
      );
}

/// Main user model
class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;
  final int totalStars;
  final int storiesCompleted;
  final List<String> favoriteStoryIds;
  final Map<String, StoryProgress> storyProgress;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGuest = false,
    this.totalStars = 0,
    this.storiesCompleted = 0,
    this.favoriteStoryIds = const [],
    this.storyProgress = const {},
    this.preferences = const UserPreferences(),
    required this.createdAt,
    required this.updatedAt,
  });

  String get firstName => displayName?.split(' ').first ?? 'Reader';

  factory UserModel.guest() => UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        isGuest: true,
        displayName: 'Guest Reader',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        isGuest: json['isGuest'] as bool? ?? false,
        totalStars: json['totalStars'] as int? ?? 0,
        storiesCompleted: json['completedCount'] as int? ??
            json['storiesCompleted'] as int? ??
            0,
        favoriteStoryIds: List<String>.from(json['favoriteStoryIds'] ?? []),
        storyProgress: (json['storyProgress'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                  k, StoryProgress.fromJson(v as Map<String, dynamic>)),
            ) ??
            {},
        preferences: json['preferences'] != null
            ? UserPreferences.fromJson(
                json['preferences'] as Map<String, dynamic>)
            : const UserPreferences(),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isGuest': isGuest,
        'totalStars': totalStars,
        'storiesCompleted': storiesCompleted,
        'favoriteStoryIds': favoriteStoryIds,
        'storyProgress': storyProgress.map((k, v) => MapEntry(k, v.toJson())),
        'preferences': preferences.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isGuest,
    int? totalStars,
    int? storiesCompleted,
    List<String>? favoriteStoryIds,
    Map<String, StoryProgress>? storyProgress,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        isGuest: isGuest ?? this.isGuest,
        totalStars: totalStars ?? this.totalStars,
        storiesCompleted: storiesCompleted ?? this.storiesCompleted,
        favoriteStoryIds: favoriteStoryIds ?? this.favoriteStoryIds,
        storyProgress: storyProgress ?? this.storyProgress,
        preferences: preferences ?? this.preferences,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
