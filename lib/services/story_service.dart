import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuwentobuddy/models/story_model.dart';
import 'package:kuwentobuddy/services/story_data.dart';

class StoryService {
  static final StoryService _instance = StoryService._internal();
  factory StoryService() => _instance;
  StoryService._internal() {
    _stories = List<StoryModel>.from(_localStories);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<StoryModel> _localStories = [
    ...filipinoTalesData,
    ...adventureJourneyData,
    ...socialStoriesData,
  ];
  List<StoryModel> _stories = [];
  bool _isInitialized = false;

  Future<void> initialize({bool preferFirestore = true}) async {
    if (_isInitialized) {
      return;
    }

    _stories = List<StoryModel>.from(_localStories);

    if (preferFirestore) {
      try {
        final remoteStories = await loadStoriesFromFirestore(
          fallbackToLocal: false,
        );
        if (remoteStories.isNotEmpty) {
          _stories = remoteStories;
        }
      } catch (_) {
        _stories = List<StoryModel>.from(_localStories);
      }
    }

    _isInitialized = true;
  }

  List<StoryModel> getAllStories() => _stories;

  StoryModel? getStoryById(String id) {
    try {
      return _stories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<StoryModel> getStoriesByCategory(StoryCategory category) {
    return _stories.where((s) => s.categories.contains(category)).toList();
  }

  List<StoryModel> getFilipinoTales() =>
      getStoriesByCategory(StoryCategory.filipinoTales);
  List<StoryModel> getAdventureJourneyStories() =>
      getStoriesByCategory(StoryCategory.adventureJourney);
  List<StoryModel> getSocialStories() =>
      getStoriesByCategory(StoryCategory.socialStories);

  List<StoryModel> getRecommendedStories() {
    return _stories.take(5).toList();
  }

  Future<void> seedStoriesToFirestore({bool overwrite = false}) async {
    final batch = _firestore.batch();

    for (final story in _localStories) {
      final docRef = _firestore.collection('stories').doc(story.id);
      final payload = story.toJson();

      if (overwrite) {
        batch.set(docRef, payload);
      } else {
        batch.set(docRef, payload, SetOptions(merge: true));
      }
    }

    await batch.commit();
  }

  Future<bool> seedStoriesToFirestoreIfMissing() async {
    final snapshot = await _firestore.collection('stories').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return false;
    }

    await seedStoriesToFirestore(overwrite: false);
    return true;
  }

  Future<List<StoryModel>> loadStoriesFromFirestore({
    bool fallbackToLocal = true,
  }) async {
    try {
      final snapshot = await _firestore.collection('stories').get();
      final remoteStories = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = data['id'] ?? doc.id;
        return StoryModel.fromJson(data);
      }).toList();

      if (remoteStories.isNotEmpty) {
        return _mergeStories(_localStories, remoteStories);
      }

      if (!fallbackToLocal) {
        return remoteStories;
      }
    } catch (_) {
      if (!fallbackToLocal) rethrow;
    }

    return _localStories;
  }

  List<StoryModel> _mergeStories(
    List<StoryModel> localStories,
    List<StoryModel> remoteStories,
  ) {
    final mergedById = <String, StoryModel>{
      for (final story in remoteStories) story.id: story,
    };

    for (final story in localStories) {
      mergedById[story.id] = story;
    }

    final mergedStories = <StoryModel>[];
    final addedIds = <String>{};

    for (final story in localStories) {
      mergedStories.add(mergedById[story.id]!);
      addedIds.add(story.id);
    }

    for (final story in remoteStories) {
      if (addedIds.add(story.id)) {
        mergedStories.add(story);
      }
    }

    return mergedStories;
  }

  List<StoryModel> searchStories(String query) {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) {
      return [];
    }

    return _stories
        .where((story) =>
            story.title.toLowerCase().contains(lowerQuery) ||
            story.description.toLowerCase().contains(lowerQuery) ||
            story.author.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
