import 'package:kuwentobuddy/models/question_model.dart';

/// Difficulty levels for stories
enum StoryLevel { beginner, intermediate, advanced }

/// Category tags for stories
enum StoryCategory { filipinoTales, adventure, fantasy, nature, quickReads }

/// A segment of a story with optional question checkpoint
class StorySegment {
  final String id;
  final String content;
  final String? image; // Optional illustration per segment
  final QuestionModel? question; // If null, no checkpoint at this segment

  const StorySegment({
    required this.id,
    required this.content,
    this.image,
    this.question,
  });

  factory StorySegment.fromJson(Map<String, dynamic> json) => StorySegment(
        id: json['id'] as String,
        content: json['content'] as String,
        image: json['image'] as String?,
        question: json['question'] != null
            ? QuestionModel.fromJson(json['question'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'image': image,
        'question': question?.toJson(),
      };
}

/// Main story model containing all story data
class StoryModel {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String description;
  final StoryLevel level;
  final List<StoryCategory> categories;
  final List<StorySegment> segments;
  final int estimatedMinutes;
  final String language; // 'en' or 'fil' for TTS
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.description,
    required this.level,
    required this.categories,
    required this.segments,
    required this.estimatedMinutes,
    this.language = 'en',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the total number of segments
  int get totalSegments => segments.length;

  /// Get segments that have questions (checkpoints)
  List<StorySegment> get checkpoints =>
      segments.where((s) => s.question != null).toList();

  /// Get level display string
  String get levelDisplay {
    switch (level) {
      case StoryLevel.beginner:
        return 'Beginner';
      case StoryLevel.intermediate:
        return 'Intermediate';
      case StoryLevel.advanced:
        return 'Advanced';
    }
  }

  /// Get level color
  String get levelEmoji {
    switch (level) {
      case StoryLevel.beginner:
        return '🌱';
      case StoryLevel.intermediate:
        return '🌿';
      case StoryLevel.advanced:
        return '🌳';
    }
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        coverImage: json['coverImage'] as String,
        description: json['description'] as String,
        level: StoryLevel.values.firstWhere(
          (e) => e.name == json['level'],
          orElse: () => StoryLevel.beginner,
        ),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => StoryCategory.values.firstWhere(
                  (c) => c.name == e,
                  orElse: () => StoryCategory.adventure,
                ))
            .toList(),
        segments: (json['segments'] as List<dynamic>)
            .map((e) => StorySegment.fromJson(e as Map<String, dynamic>))
            .toList(),
        estimatedMinutes: json['estimatedMinutes'] as int,
        language: json['language'] as String? ?? 'en',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'coverImage': coverImage,
        'description': description,
        'level': level.name,
        'categories': categories.map((e) => e.name).toList(),
        'segments': segments.map((e) => e.toJson()).toList(),
        'estimatedMinutes': estimatedMinutes,
        'language': language,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  StoryModel copyWith({
    String? id,
    String? title,
    String? author,
    String? coverImage,
    String? description,
    StoryLevel? level,
    List<StoryCategory>? categories,
    List<StorySegment>? segments,
    int? estimatedMinutes,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      StoryModel(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        coverImage: coverImage ?? this.coverImage,
        description: description ?? this.description,
        level: level ?? this.level,
        categories: categories ?? this.categories,
        segments: segments ?? this.segments,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        language: language ?? this.language,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
