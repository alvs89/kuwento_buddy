import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuwentobuddy/models/user_model.dart';

class ChildProfileModel {
  final String id;
  final String parentId;
  final String displayName;
  final String avatarAsset;
  final int totalStars;
  final int storiesCompleted;
  final List<String> favoriteStoryIds;
  final Map<String, StoryProgress> storyProgress;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChildProfileModel({
    required this.id,
    required this.parentId,
    required this.displayName,
    required this.avatarAsset,
    this.totalStars = 0,
    this.storiesCompleted = 0,
    this.favoriteStoryIds = const [],
    this.storyProgress = const {},
    this.preferences = const UserPreferences(),
    required this.createdAt,
    required this.updatedAt,
  });

  String get firstName => displayName.split(' ').first;

  factory ChildProfileModel.fromJson(Map<String, dynamic> json, String id) =>
      ChildProfileModel(
        id: id,
        parentId: json['parentId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? 'Reader',
        avatarAsset:
            json['avatarAsset'] as String? ?? 'assets/icons/avatar_default.png',
        totalStars: json['totalStars'] as int? ?? 0,
        storiesCompleted: json['storiesCompleted'] as int? ?? 0,
        favoriteStoryIds: List<String>.from(json['favoriteStoryIds'] ?? []),
        storyProgress: (json['storyProgress'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                  key, StoryProgress.fromJson(value as Map<String, dynamic>)),
            ) ??
            const {},
        preferences: json['preferences'] != null
            ? UserPreferences.fromJson(json['preferences'])
            : const UserPreferences(),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'parentId': parentId,
        'displayName': displayName,
        'avatarAsset': avatarAsset,
        'totalStars': totalStars,
        'storiesCompleted': storiesCompleted,
        'favoriteStoryIds': favoriteStoryIds,
        'storyProgress':
            storyProgress.map((key, value) => MapEntry(key, value.toJson())),
        'preferences': preferences.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  ChildProfileModel copyWith({
    String? displayName,
    String? avatarAsset,
    int? totalStars,
    int? storiesCompleted,
    List<String>? favoriteStoryIds,
    Map<String, StoryProgress>? storyProgress,
    UserPreferences? preferences,
    DateTime? updatedAt,
  }) =>
      ChildProfileModel(
        id: id,
        parentId: parentId,
        displayName: displayName ?? this.displayName,
        avatarAsset: avatarAsset ?? this.avatarAsset,
        totalStars: totalStars ?? this.totalStars,
        storiesCompleted: storiesCompleted ?? this.storiesCompleted,
        favoriteStoryIds: favoriteStoryIds ?? this.favoriteStoryIds,
        storyProgress: storyProgress ?? this.storyProgress,
        preferences: preferences ?? this.preferences,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}
