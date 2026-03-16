import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/services/story_service.dart';

/// Service for managing user data in Firestore
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StoryService _storyService = StoryService();
  final String _collection = 'users';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(_collection).doc(uid);

  CollectionReference<Map<String, dynamic>> _progressCol(String uid) =>
      _userDoc(uid).collection('storyProgress');

  CollectionReference<Map<String, dynamic>> _favoritesCol(String uid) =>
      _userDoc(uid).collection('favorites');

  CollectionReference<Map<String, dynamic>> _completedCol(String uid) =>
      _userDoc(uid).collection('completedStories');

  /// Get or create user
  Future<UserModel> getOrCreateUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    final docRef = _userDoc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'totalStars': 0,
        'storiesCompleted': 0,
        'progressCount': 0,
        'favoritesCount': 0,
        'completedCount': 0,
        'favoriteStoryIds': <String>[], // Legacy compatibility
        'storyProgress': <String, dynamic>{}, // Legacy compatibility
        'preferences': const UserPreferences().toJson(),
        'schemaVersion': 2,
        'isGuest': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await docRef.set({
        'displayName': displayName ?? doc.data()?['displayName'],
        'email': email ?? doc.data()?['email'],
        'photoUrl': photoUrl ?? doc.data()?['photoUrl'],
        'schemaVersion': 2,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final hydrated = await getUser(uid);
    if (hydrated != null) return hydrated;

    return UserModel(
      id: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isGuest: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final userDoc = await _userDoc(uid).get();
      if (!userDoc.exists) return null;

      final baseData = Map<String, dynamic>.from(userDoc.data() ?? {});
      final progressSnap = await _progressCol(uid).get();
      final favoritesSnap = await _favoritesCol(uid).get();
      final completedSnap = await _completedCol(uid).get();

      final subProgress = <String, StoryProgress>{};
      for (final doc in progressSnap.docs) {
        final data = doc.data();
        final appStoryId = _resolveAppStoryId(
          firestoreDocId: doc.id,
          firestoreStoryIdentifier: data['storyId'] as String?,
          firestoreStoryTitle: data['storyTitle'] as String?,
        );
        final progress = StoryProgress(
          storyId: appStoryId,
          storyTitle: _resolveStoryTitle(
            appStoryId,
            fallback: data['storyTitle'] as String? ?? doc.id,
          ),
          currentSegmentIndex: data['currentSegmentIndex'] as int? ??
              data['lastPage'] as int? ??
              0,
          totalSegments: data['totalSegments'] as int? ?? 0,
          isCompleted: data['isCompleted'] as bool? ??
              data['completed'] as bool? ??
              false,
          correctAnswers: data['correctAnswers'] as int? ?? 0,
          totalQuestions: data['totalQuestions'] as int? ?? 0,
          starsEarned: data['starsEarned'] as int? ?? 0,
          skillCorrect: Map<String, int>.from(data['skillCorrect'] ?? {}),
          skillTotal: Map<String, int>.from(data['skillTotal'] ?? {}),
          startedAt: _asDateTime(data['startedAt']) ?? DateTime.now(),
          completedAt: _asDateTime(data['completedAt']),
          updatedAt: _asDateTime(data['updatedAt']) ?? DateTime.now(),
        );
        subProgress[progress.storyId] = progress;
      }

      // Keep completed stories visible to UI compatibility consumers even when
      // canonical storage is in completedStories subcollection.
      for (final doc in completedSnap.docs) {
        final data = doc.data();
        final appStoryId = _resolveAppStoryId(
          firestoreDocId: doc.id,
          firestoreStoryIdentifier: data['storyId'] as String?,
          firestoreStoryTitle: data['storyTitle'] as String?,
        );

        if (subProgress.containsKey(appStoryId)) continue;

        final startedAt = _asDateTime(data['completedAt']) ?? DateTime.now();
        final completedAt = _asDateTime(data['completedAt']) ?? DateTime.now();

        subProgress[appStoryId] = StoryProgress(
          storyId: appStoryId,
          storyTitle: _resolveStoryTitle(
            appStoryId,
            fallback: data['storyTitle'] as String?,
          ),
          isCompleted: true,
          startedAt: startedAt,
          completedAt: completedAt,
          updatedAt: completedAt,
        );
      }

      final subFavorites = favoritesSnap.docs
          .map((d) => _resolveAppStoryId(
                firestoreDocId: d.id,
                firestoreStoryIdentifier: d.data()['storyId'] as String?,
                firestoreStoryTitle: d.data()['storyTitle'] as String?,
              ).trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final legacyProgress =
          (baseData['storyProgress'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(
                  k,
                  StoryProgress.fromJson(v as Map<String, dynamic>),
                ),
              ) ??
              {};

      final legacyFavorites =
          List<String>.from(baseData['favoriteStoryIds'] ?? const <String>[]);

      final mergedFavorites =
          subFavorites.isNotEmpty ? subFavorites : legacyFavorites;
      final completedCount = completedSnap.docs.length;
      final progressCount = progressSnap.docs.length;
      final favoritesCount = mergedFavorites.toSet().length;

      final existingProgressCount = baseData['progressCount'] as int?;
      final existingFavoritesCount = baseData['favoritesCount'] as int?;
      final existingCompletedCount = baseData['completedCount'] as int?;

      if (existingProgressCount != progressCount ||
          existingFavoritesCount != favoritesCount ||
          existingCompletedCount != completedCount) {
        await _userDoc(uid).set({
          'progressCount': progressCount,
          'favoritesCount': favoritesCount,
          'completedCount': completedCount,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await _backfillStoryTitlesIfNeeded(
        userId: uid,
        progressSnap: progressSnap,
        favoritesSnap: favoritesSnap,
        completedSnap: completedSnap,
        legacyProgress: legacyProgress,
        legacyFavorites: legacyFavorites,
        hasLegacyProgressField: baseData.containsKey('storyProgress'),
        hasLegacyFavoritesField: baseData.containsKey('favoriteStoryIds'),
      );

      // Re-read canonical subcollections after migration/backfill so anything
      // shown in UI directly reflects Firestore source-of-truth collections.
      final canonicalProgressSnap = await _progressCol(uid).get();
      final canonicalFavoritesSnap = await _favoritesCol(uid).get();
      final canonicalCompletedSnap = await _completedCol(uid).get();

      final canonicalProgress = <String, StoryProgress>{};
      for (final doc in canonicalProgressSnap.docs) {
        final data = doc.data();
        final appStoryId = _resolveAppStoryId(
          firestoreDocId: doc.id,
          firestoreStoryIdentifier: data['storyId'] as String?,
          firestoreStoryTitle: data['storyTitle'] as String?,
        );

        canonicalProgress[appStoryId] = StoryProgress(
          storyId: appStoryId,
          storyTitle: _resolveStoryTitle(
            appStoryId,
            fallback: data['storyTitle'] as String?,
          ),
          currentSegmentIndex: data['currentSegmentIndex'] as int? ??
              data['lastPage'] as int? ??
              0,
          totalSegments: data['totalSegments'] as int? ?? 0,
          isCompleted: false,
          correctAnswers: data['correctAnswers'] as int? ?? 0,
          totalQuestions: data['totalQuestions'] as int? ?? 0,
          starsEarned: data['starsEarned'] as int? ?? 0,
          skillCorrect: Map<String, int>.from(data['skillCorrect'] ?? {}),
          skillTotal: Map<String, int>.from(data['skillTotal'] ?? {}),
          startedAt: _asDateTime(data['startedAt']) ?? DateTime.now(),
          completedAt: null,
          updatedAt: _asDateTime(data['updatedAt']) ?? DateTime.now(),
        );
      }

      // Include completed stories from canonical completedStories for
      // compatibility with existing UI logic in Completed tab.
      for (final doc in canonicalCompletedSnap.docs) {
        final data = doc.data();
        final appStoryId = _resolveAppStoryId(
          firestoreDocId: doc.id,
          firestoreStoryIdentifier: data['storyId'] as String?,
          firestoreStoryTitle: data['storyTitle'] as String?,
        );

        if (canonicalProgress.containsKey(appStoryId)) continue;

        final completedAt = _asDateTime(data['completedAt']) ?? DateTime.now();
        canonicalProgress[appStoryId] = StoryProgress(
          storyId: appStoryId,
          storyTitle: _resolveStoryTitle(
            appStoryId,
            fallback: data['storyTitle'] as String?,
          ),
          isCompleted: true,
          startedAt: completedAt,
          completedAt: completedAt,
          updatedAt: completedAt,
        );
      }

      final canonicalFavorites = canonicalFavoritesSnap.docs
          .map((d) => _resolveAppStoryId(
                firestoreDocId: d.id,
                firestoreStoryIdentifier: d.data()['storyId'] as String?,
                firestoreStoryTitle: d.data()['storyTitle'] as String?,
              ).trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      return UserModel.fromJson({
        ...baseData,
        'id': uid,
        'storyProgress':
            canonicalProgress.map((k, v) => MapEntry(k, v.toJson())),
        'favoriteStoryIds': canonicalFavorites,
      });
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _userDoc(user.id).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'totalStars': user.totalStars,
        'storiesCompleted': user.storiesCompleted,
        'preferences': user.preferences.toJson(),
        'schemaVersion': 2,
        'createdAt': Timestamp.fromDate(user.createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Canonical persistence lives in subcollections for scalability.
      for (final entry in user.storyProgress.entries) {
        if (entry.value.isCompleted) {
          await _deleteProgressDoc(
            user.id,
            appStoryId: entry.key,
            fallbackTitle: entry.value.storyTitle,
          );
          continue;
        }
        await _writeStoryProgress(user.id, entry.value);
      }

      await _syncFavoritesCollection(
          userId: user.id, favoriteStoryIds: user.favoriteStoryIds);

      for (final entry in user.storyProgress.entries) {
        if (entry.value.isCompleted) {
          final storyKey = _storyKeyForFirestore(
            appStoryId: entry.key,
            fallbackTitle: entry.value.storyTitle,
          );

          await _completedCol(user.id).doc(storyKey).set({
            'storyId': storyKey,
            'storyTitle': _resolveStoryTitle(
              entry.key,
              fallback: entry.value.storyTitle,
            ),
            'score': entry.value.comprehensionScore,
            'completedAt': entry.value.completedAt != null
                ? Timestamp.fromDate(entry.value.completedAt!)
                : FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      await _syncUserCountsFromSubcollections(user.id);
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  /// Update story progress
  Future<void> updateStoryProgress(
      String userId, StoryProgress progress) async {
    try {
      await _userDoc(userId).set({
        'schemaVersion': 2,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (progress.isCompleted) {
        final storyKey = _storyKeyForFirestore(
          appStoryId: progress.storyId,
          fallbackTitle: progress.storyTitle,
        );

        await _completedCol(userId).doc(storyKey).set({
          'storyId': storyKey,
          'storyTitle': _resolveStoryTitle(
            progress.storyId,
            fallback: progress.storyTitle,
          ),
          'score': progress.comprehensionScore,
          'completedAt': progress.completedAt != null
              ? Timestamp.fromDate(progress.completedAt!)
              : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _deleteProgressDoc(
          userId,
          appStoryId: progress.storyId,
          fallbackTitle: progress.storyTitle,
        );
      } else {
        await _writeStoryProgress(userId, progress);
      }

      await _syncUserCountsFromSubcollections(userId);
    } catch (e) {
      debugPrint('Error updating story progress: $e');
      rethrow;
    }
  }

  /// Add stars to user
  Future<void> addStars(String userId, int stars) async {
    try {
      await _userDoc(userId).set({
        'totalStars': FieldValue.increment(stars),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding stars: $e');
      rethrow;
    }
  }

  /// Increment stories completed
  Future<void> incrementStoriesCompleted(String userId) async {
    try {
      await _userDoc(userId).set({
        'storiesCompleted': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error incrementing stories completed: $e');
      rethrow;
    }
  }

  /// Toggle favorite story
  Future<void> toggleFavorite(String userId, String storyId, bool isFavorite,
      {String? storyTitle}) async {
    try {
      await _userDoc(userId).set({
        'schemaVersion': 2,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (isFavorite) {
        await _upsertFavoriteDoc(
          userId: userId,
          appStoryId: storyId,
          storyTitle: _resolveStoryTitle(storyId, fallback: storyTitle),
        );
      } else {
        final storyKey = _storyKeyForFirestore(
          appStoryId: storyId,
          fallbackTitle: storyTitle,
        );
        await _favoritesCol(userId).doc(storyKey).delete();
      }

      await _syncUserCountsFromSubcollections(userId);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(
      String userId, UserPreferences preferences) async {
    try {
      await _userDoc(userId).set({
        'preferences': preferences.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  /// Merge guest progress to authenticated user
  Future<void> mergeProgress({
    required String userId,
    required Map<String, StoryProgress> guestProgress,
    required int guestStars,
    required int guestStoriesCompleted,
    required List<String> guestFavorites,
  }) async {
    try {
      final userRef = _userDoc(userId);
      final updates = <String, dynamic>{
        'schemaVersion': 2,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update each story progress
      for (final entry in guestProgress.entries) {
        if (entry.value.isCompleted) {
          final storyKey = _storyKeyForFirestore(
            appStoryId: entry.key,
            fallbackTitle: entry.value.storyTitle,
          );

          await _completedCol(userId).doc(storyKey).set({
            'storyId': storyKey,
            'storyTitle': _resolveStoryTitle(
              entry.key,
              fallback: entry.value.storyTitle,
            ),
            'score': entry.value.comprehensionScore,
            'completedAt': entry.value.completedAt != null
                ? Timestamp.fromDate(entry.value.completedAt!)
                : FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await _deleteProgressDoc(
            userId,
            appStoryId: entry.key,
            fallbackTitle: entry.value.storyTitle,
          );
        } else {
          await _writeStoryProgress(userId, entry.value);
        }
      }

      // Add stars and completed stories
      if (guestStars > 0) {
        updates['totalStars'] = FieldValue.increment(guestStars);
      }
      if (guestStoriesCompleted > 0) {
        updates['storiesCompleted'] =
            FieldValue.increment(guestStoriesCompleted);
      }
      if (guestFavorites.isNotEmpty) {
        for (final storyId in guestFavorites.toSet()) {
          await _upsertFavoriteDoc(
            userId: userId,
            appStoryId: storyId,
            storyTitle: _resolveStoryTitle(storyId),
          );
        }
      }

      await userRef.set(updates, SetOptions(merge: true));

      await _syncUserCountsFromSubcollections(userId);
    } catch (e) {
      debugPrint('Error merging progress: $e');
      rethrow;
    }
  }

  Future<void> _syncUserCountsFromSubcollections(String userId) async {
    final progressSnap = await _progressCol(userId).get();
    final favoritesSnap = await _favoritesCol(userId).get();
    final completedSnap = await _completedCol(userId).get();

    await _userDoc(userId).set({
      'progressCount': progressSnap.docs.length,
      'favoritesCount': favoritesSnap.docs.length,
      'completedCount': completedSnap.docs.length,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _writeStoryProgress(
      String userId, StoryProgress progress) async {
    final storyKey = _storyKeyForFirestore(
      appStoryId: progress.storyId,
      fallbackTitle: progress.storyTitle,
    );
    final resolvedTitle = _resolveStoryTitle(
      progress.storyId,
      fallback: progress.storyTitle,
    );

    await _progressCol(userId).doc(storyKey).set({
      'storyId': storyKey,
      if (resolvedTitle != null) 'storyTitle': resolvedTitle,
      'currentSegmentIndex': progress.currentSegmentIndex,
      'comprehensionScore': progress.comprehensionScore,
      'isCompleted': false,
      'correctAnswers': progress.correctAnswers,
      'totalQuestions': progress.totalQuestions,
      'starsEarned': progress.starsEarned,
      'totalSegments': progress.totalSegments,
      'skillCorrect': progress.skillCorrect,
      'skillTotal': progress.skillTotal,
      'startedAt': Timestamp.fromDate(progress.startedAt),
      'completedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _deleteProgressDoc(
    String userId, {
    required String appStoryId,
    String? fallbackTitle,
  }) async {
    final storyKey = _storyKeyForFirestore(
      appStoryId: appStoryId,
      fallbackTitle: fallbackTitle,
    );

    await _progressCol(userId).doc(storyKey).delete();

    // Backward compatibility: clean legacy ID-keyed docs if any remain.
    if (storyKey != appStoryId) {
      await _progressCol(userId).doc(appStoryId).delete();
    }
  }

  Future<void> _syncFavoritesCollection({
    required String userId,
    required List<String> favoriteStoryIds,
  }) async {
    final desired = favoriteStoryIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final desiredKeys =
        desired.map((id) => _storyKeyForFirestore(appStoryId: id)).toSet();

    final existingDocs = await _favoritesCol(userId).get();
    final existing = existingDocs.docs.map((doc) => doc.id).toSet();

    for (final storyId in desired) {
      await _upsertFavoriteDoc(
        userId: userId,
        appStoryId: storyId,
        storyTitle: _resolveStoryTitle(storyId),
      );
    }

    for (final storyKey in existing.difference(desiredKeys)) {
      await _favoritesCol(userId).doc(storyKey).delete();
    }
  }

  Future<void> _upsertFavoriteDoc({
    required String userId,
    required String appStoryId,
    String? storyTitle,
  }) async {
    final storyKey = _storyKeyForFirestore(
      appStoryId: appStoryId,
      fallbackTitle: storyTitle,
    );
    final ref = _favoritesCol(userId).doc(storyKey);
    final existing = await ref.get();
    final resolvedTitle = _resolveStoryTitle(appStoryId, fallback: storyTitle);

    await ref.set({
      'storyId': storyKey,
      'storyTitle': resolvedTitle ?? storyKey,
      'addedAt': existing.exists && existing.data()?['addedAt'] != null
          ? existing.data()!['addedAt']
          : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _storyKeyForFirestore({
    required String appStoryId,
    String? fallbackTitle,
  }) {
    final resolved = _resolveStoryTitle(appStoryId, fallback: fallbackTitle);
    return (resolved ?? appStoryId).trim();
  }

  String _resolveAppStoryId({
    required String firestoreDocId,
    String? firestoreStoryIdentifier,
    String? firestoreStoryTitle,
  }) {
    final candidates = <String>[
      firestoreStoryIdentifier ?? '',
      firestoreDocId,
      firestoreStoryTitle ?? '',
    ].map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    for (final candidate in candidates) {
      final byId = _storyService.getStoryById(candidate);
      if (byId != null) return byId.id;

      final byTitle = _storyService.getAllStories().where(
            (story) =>
                story.title.trim().toLowerCase() == candidate.toLowerCase(),
          );
      if (byTitle.isNotEmpty) return byTitle.first.id;
    }

    return firestoreStoryIdentifier?.trim().isNotEmpty == true
        ? firestoreStoryIdentifier!.trim()
        : firestoreDocId.trim();
  }

  String? _resolveStoryTitle(String storyId, {String? fallback}) {
    final trimmedFallback = fallback?.trim();
    final story = _storyService.getStoryById(storyId);
    if (story != null && story.title.trim().isNotEmpty) {
      return story.title.trim();
    }
    if (trimmedFallback != null &&
        trimmedFallback.isNotEmpty &&
        trimmedFallback.toLowerCase() != storyId.trim().toLowerCase()) {
      return trimmedFallback;
    }
    return null;
  }

  Future<void> _backfillStoryTitlesIfNeeded({
    required String userId,
    required QuerySnapshot<Map<String, dynamic>> progressSnap,
    required QuerySnapshot<Map<String, dynamic>> favoritesSnap,
    required QuerySnapshot<Map<String, dynamic>> completedSnap,
    required Map<String, StoryProgress> legacyProgress,
    required List<String> legacyFavorites,
    required bool hasLegacyProgressField,
    required bool hasLegacyFavoritesField,
  }) async {
    final writes = _firestore.batch();
    var hasWrites = false;
    final hasSubProgress = progressSnap.docs.isNotEmpty;
    final hasSubFavorites = favoritesSnap.docs.isNotEmpty;

    if (!hasSubProgress && legacyProgress.isNotEmpty) {
      for (final entry in legacyProgress.entries) {
        final storyId = entry.key.trim();
        if (storyId.isEmpty) continue;

        final legacy = entry.value;
        final storyKey = _storyKeyForFirestore(
          appStoryId: storyId,
          fallbackTitle: legacy.storyTitle,
        );
        final resolvedTitle =
            _resolveStoryTitle(storyId, fallback: legacy.storyTitle);

        if (legacy.isCompleted) {
          writes.set(
              _completedCol(userId).doc(storyKey),
              {
                'storyId': storyKey,
                if (resolvedTitle != null) 'storyTitle': resolvedTitle,
                'score': legacy.comprehensionScore,
                'completedAt': legacy.completedAt != null
                    ? Timestamp.fromDate(legacy.completedAt!)
                    : FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true));
          hasWrites = true;
        } else {
          writes.set(
              _progressCol(userId).doc(storyKey),
              {
                'storyId': storyKey,
                if (resolvedTitle != null) 'storyTitle': resolvedTitle,
                'currentSegmentIndex': legacy.currentSegmentIndex,
                'comprehensionScore': legacy.comprehensionScore,
                'isCompleted': false,
                'correctAnswers': legacy.correctAnswers,
                'totalQuestions': legacy.totalQuestions,
                'starsEarned': legacy.starsEarned,
                'totalSegments': legacy.totalSegments,
                'skillCorrect': legacy.skillCorrect,
                'skillTotal': legacy.skillTotal,
                'startedAt': Timestamp.fromDate(legacy.startedAt),
                'completedAt': null,
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true));
          hasWrites = true;
        }
      }
    }

    if (!hasSubFavorites && legacyFavorites.isNotEmpty) {
      for (final id in legacyFavorites.toSet()) {
        final storyId = id.trim();
        if (storyId.isEmpty) continue;
        final storyKey = _storyKeyForFirestore(appStoryId: storyId);
        final resolvedTitle = _resolveStoryTitle(storyId);

        writes.set(
            _favoritesCol(userId).doc(storyKey),
            {
              'storyId': storyKey,
              'storyTitle': resolvedTitle ?? storyKey,
              'addedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        hasWrites = true;
      }
    }

    for (final doc in progressSnap.docs) {
      final data = doc.data();
      final appStoryId = _resolveAppStoryId(
        firestoreDocId: doc.id,
        firestoreStoryIdentifier: data['storyId'] as String?,
        firestoreStoryTitle: data['storyTitle'] as String?,
      );
      final storyKey = _storyKeyForFirestore(
        appStoryId: appStoryId,
        fallbackTitle: data['storyTitle'] as String?,
      );
      if (storyKey.isEmpty) continue;

      final resolvedTitle = _resolveStoryTitle(
        appStoryId,
        fallback: data['storyTitle'] as String?,
      );

      if (doc.id.trim() != storyKey) {
        writes.set(
            _progressCol(userId).doc(storyKey),
            {
              ...data,
              'storyId': storyKey,
              if (resolvedTitle != null) 'storyTitle': resolvedTitle,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        writes.delete(_progressCol(userId).doc(doc.id));
        hasWrites = true;
      }

      final isCompletedInProgress =
          (data['isCompleted'] as bool? ?? data['completed'] as bool? ?? false);

      if (isCompletedInProgress) {
        final completedAt = _asDateTime(data['completedAt']) ?? DateTime.now();
        writes.set(
            _completedCol(userId).doc(storyKey),
            {
              'storyId': storyKey,
              if (resolvedTitle != null) 'storyTitle': resolvedTitle,
              'score': (data['comprehensionScore'] as num?)?.toDouble() ?? 0,
              'completedAt': Timestamp.fromDate(completedAt),
            },
            SetOptions(merge: true));
        writes.delete(_progressCol(userId).doc(storyKey));
        if (doc.id.trim() != storyKey) {
          writes.delete(_progressCol(userId).doc(doc.id));
        }
        hasWrites = true;
        continue;
      }

      if (resolvedTitle != null &&
          (data['storyTitle'] as String?)?.trim() != resolvedTitle) {
        writes.set(
            _progressCol(userId).doc(storyKey),
            {
              'storyId': storyKey,
              'storyTitle': resolvedTitle,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        hasWrites = true;
      }
    }

    for (final doc in favoritesSnap.docs) {
      final data = doc.data();
      final appStoryId = _resolveAppStoryId(
        firestoreDocId: doc.id,
        firestoreStoryIdentifier: data['storyId'] as String?,
        firestoreStoryTitle: data['storyTitle'] as String?,
      );
      final storyKey = _storyKeyForFirestore(
        appStoryId: appStoryId,
        fallbackTitle: data['storyTitle'] as String?,
      );
      if (storyKey.isEmpty) continue;

      final resolvedTitle = _resolveStoryTitle(
        appStoryId,
        fallback: data['storyTitle'] as String?,
      );

      if (doc.id.trim() != storyKey) {
        writes.set(
            _favoritesCol(userId).doc(storyKey),
            {
              ...data,
              'storyId': storyKey,
              if (resolvedTitle != null) 'storyTitle': resolvedTitle,
            },
            SetOptions(merge: true));
        writes.delete(_favoritesCol(userId).doc(doc.id));
        hasWrites = true;
      }

      if (resolvedTitle != null &&
          (data['storyTitle'] as String?)?.trim() != resolvedTitle) {
        writes.set(
            _favoritesCol(userId).doc(storyKey),
            {
              'storyId': storyKey,
              'storyTitle': resolvedTitle,
            },
            SetOptions(merge: true));
        hasWrites = true;
      }
    }

    for (final doc in completedSnap.docs) {
      final data = doc.data();
      final appStoryId = _resolveAppStoryId(
        firestoreDocId: doc.id,
        firestoreStoryIdentifier: data['storyId'] as String?,
        firestoreStoryTitle: data['storyTitle'] as String?,
      );
      final storyKey = _storyKeyForFirestore(
        appStoryId: appStoryId,
        fallbackTitle: data['storyTitle'] as String?,
      );
      if (storyKey.isEmpty) continue;

      final resolvedTitle = _resolveStoryTitle(
        appStoryId,
        fallback: data['storyTitle'] as String?,
      );

      if (doc.id.trim() != storyKey) {
        writes.set(
            _completedCol(userId).doc(storyKey),
            {
              ...data,
              'storyId': storyKey,
              if (resolvedTitle != null) 'storyTitle': resolvedTitle,
            },
            SetOptions(merge: true));
        writes.delete(_completedCol(userId).doc(doc.id));
        hasWrites = true;
      }

      if (resolvedTitle != null &&
          (data['storyTitle'] as String?)?.trim() != resolvedTitle) {
        writes.set(
            _completedCol(userId).doc(storyKey),
            {
              'storyId': storyKey,
              'storyTitle': resolvedTitle,
            },
            SetOptions(merge: true));
        hasWrites = true;
      }
    }

    final shouldPruneLegacyProgress =
        hasLegacyProgressField && (hasSubProgress || legacyProgress.isNotEmpty);
    final shouldPruneLegacyFavorites = hasLegacyFavoritesField &&
        (hasSubFavorites || legacyFavorites.isNotEmpty);

    if (shouldPruneLegacyProgress || shouldPruneLegacyFavorites) {
      writes.set(
          _userDoc(userId),
          {
            if (shouldPruneLegacyProgress) 'storyProgress': FieldValue.delete(),
            if (shouldPruneLegacyFavorites)
              'favoriteStoryIds': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
      hasWrites = true;
    }

    if (hasWrites) {
      await writes.commit();
    }
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
