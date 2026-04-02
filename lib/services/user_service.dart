import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';

import 'package:kuwentobuddy/models/user_model.dart';
import 'package:kuwentobuddy/models/child_profile_model.dart';

import 'package:kuwentobuddy/services/story_service.dart';

/// Service for managing user data in Firestore

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StoryService _storyService = StoryService();

  final String _collection = 'users';

  String? _activeProfileId;

  void setActiveProfileId(String? profileId) {
    _activeProfileId = profileId;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(_collection).doc(uid);

  DocumentReference<Map<String, dynamic>> _targetDoc(String uid) {
    if (_activeProfileId != null) {
      return _userDoc(uid).collection('profiles').doc(_activeProfileId);
    }
    return _userDoc(uid);
  }

  CollectionReference<Map<String, dynamic>> _progressCol(String uid) =>
      _targetDoc(uid).collection('storyProgress');

  CollectionReference<Map<String, dynamic>> _favoritesCol(String uid) =>
      _targetDoc(uid).collection('favorites');

  CollectionReference<Map<String, dynamic>> _completedCol(String uid) =>
      _targetDoc(uid).collection('completedStories');

  CollectionReference<Map<String, dynamic>> _profilesCol(String uid) =>
      _userDoc(uid).collection('profiles');

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
      final existingData = Map<String, dynamic>.from(doc.data() ?? {});

      final canonical = _buildCanonicalUserDoc(
        existingData: existingData,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      );

// Overwrite document with canonical schema so unknown legacy keys

// cannot keep violating Firestore rules on every update.

      await docRef.set(canonical);
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

      final normalizedPrefs = _sanitizePreferencesMap(baseData['preferences']);

      final legacyFixes = _legacyUserFieldFixes(baseData);

      if (normalizedPrefs != null || legacyFixes.isNotEmpty) {
        await _userDoc(uid).set({
          if (normalizedPrefs != null) 'preferences': normalizedPrefs,
          ...legacyFixes,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (normalizedPrefs != null) {
          baseData['preferences'] = normalizedPrefs;
        }
      }

      final progressSnap = await _progressCol(uid).get();

      final favoritesSnap = await _favoritesCol(uid).get();

      final completedSnap = await _completedCol(uid).get();

      final subProgress = <String, StoryProgress>{};

      for (final doc in progressSnap.docs) {
        try {
          final data = doc.data();

// FIXED: Parse appStoryId FIRST (fastest match)

          String appStoryId;

          if (data['appStoryId'] is String) {
            appStoryId = (data['appStoryId'] as String).trim();

            debugPrint(
                'UserService.getUser: Found appStoryId=$appStoryId in ${doc.id}');
          } else {
          appStoryId = _resolveAppStoryId(
            firestoreDocId: doc.id,
            firestoreStoryIdentifier: data['storyId'] as String?,
            firestoreStoryTitle: data['storyTitle'] as String?,
            firestoreAppStoryId: data['appStoryId'] as String?,
          );
          }

          final progress = StoryProgress(
            storyId: appStoryId,
            storyTitle: _resolveStoryTitle(
              appStoryId,
              fallback: data['storyTitle'] as String? ?? doc.id,
            ),
            currentSegmentIndex: _asInt(data['currentSegmentIndex']) ??
                _asInt(data['lastPage']) ??
                0,
            totalSegments: _asInt(data['totalSegments']) ?? 0,
            isCompleted: data['isCompleted'] as bool? ??
                data['completed'] as bool? ??
                false,
            correctAnswers: _asInt(data['correctAnswers']) ?? 0,
            totalQuestions: _asInt(data['totalQuestions']) ?? 0,
            starsEarned: _asInt(data['starsEarned']) ?? 0,
            skillCorrect: _asStringIntMap(data['skillCorrect']),
            skillTotal: _asStringIntMap(data['skillTotal']),
            startedAt: _asDateTime(data['startedAt']) ?? DateTime.now(),
            completedAt: _asDateTime(data['completedAt']),
            updatedAt: _asDateTime(data['updatedAt']) ?? DateTime.now(),
            hintAttemptsUsed: _asInt(data['hintAttemptsUsed']) ?? 0,
          );

          subProgress[progress.storyId] = progress;
        } catch (e) {
          debugPrint('Skipping malformed progress doc ${doc.id}: $e');
        }
      }

// Keep completed stories visible to UI compatibility consumers even when

// canonical storage is in completedStories subcollection.

      for (final doc in completedSnap.docs) {
        try {
          final data = doc.data();

          final appStoryId = _resolveAppStoryId(
            firestoreDocId: doc.id,
            firestoreStoryIdentifier: data['storyId'] as String?,
            firestoreStoryTitle: data['storyTitle'] as String?,
            firestoreAppStoryId: data['appStoryId'] as String?,
          );

          final startedAt = _asDateTime(data['completedAt']) ?? DateTime.now();

          final completedAt =
              _asDateTime(data['completedAt']) ?? DateTime.now();

// Completed state must win over any lingering in-progress doc.

          subProgress[appStoryId] = StoryProgress(
            storyId: appStoryId,
            storyTitle: _resolveStoryTitle(
              appStoryId,
              fallback: data['storyTitle'] as String?,
            ),
            currentSegmentIndex: (_asInt(data['totalSegments']) ?? 1) - 1,
            totalSegments: _asInt(data['totalSegments']) ?? 0,
            isCompleted: true,
            correctAnswers: _asInt(data['correctAnswers']) ?? 0,
            totalQuestions: _asInt(data['totalQuestions']) ?? 0,
            starsEarned: _asInt(data['starsEarned']) ?? 0,
            skillCorrect: _asStringIntMap(data['skillCorrect']),
            skillTotal: _asStringIntMap(data['skillTotal']),
            startedAt: startedAt,
            completedAt: completedAt,
            updatedAt: completedAt,
            hintAttemptsUsed: _asInt(data['hintAttemptsUsed']) ?? 0,
          );
        } catch (e) {
          debugPrint('Skipping malformed completed doc ${doc.id}: $e');
        }
      }

      final subFavorites = favoritesSnap.docs
          .map((d) => _resolveAppStoryId(
                firestoreDocId: d.id,
                firestoreStoryIdentifier: d.data()['storyId'] as String?,
                firestoreStoryTitle: d.data()['storyTitle'] as String?,
                firestoreAppStoryId: d.data()['appStoryId'] as String?,
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
        try {
          final data = doc.data();

          final appStoryId = _resolveAppStoryId(
            firestoreDocId: doc.id,
            firestoreStoryIdentifier: data['storyId'] as String?,
            firestoreStoryTitle: data['storyTitle'] as String?,
            firestoreAppStoryId: data['appStoryId'] as String?,
          );

          canonicalProgress[appStoryId] = StoryProgress(
            storyId: appStoryId,
            storyTitle: _resolveStoryTitle(
              appStoryId,
              fallback: data['storyTitle'] as String?,
            ),
            currentSegmentIndex: _asInt(data['currentSegmentIndex']) ??
                _asInt(data['lastPage']) ??
                0,
            totalSegments: _asInt(data['totalSegments']) ?? 0,
            isCompleted: data['isCompleted'] as bool? ??
                data['completed'] as bool? ??
                false,
            correctAnswers: _asInt(data['correctAnswers']) ?? 0,
            totalQuestions: _asInt(data['totalQuestions']) ?? 0,
            starsEarned: _asInt(data['starsEarned']) ?? 0,
            skillCorrect: _asStringIntMap(data['skillCorrect']),
            skillTotal: _asStringIntMap(data['skillTotal']),
            startedAt: _asDateTime(data['startedAt']) ?? DateTime.now(),
            completedAt: _asDateTime(data['completedAt']),
            updatedAt: _asDateTime(data['updatedAt']) ?? DateTime.now(),
            hintAttemptsUsed: _asInt(data['hintAttemptsUsed']) ?? 0,
          );
        } catch (e) {
          debugPrint('Skipping malformed canonical progress doc ${doc.id}: $e');
        }
      }

// Include completed stories from canonical completedStories for

// compatibility with existing UI logic in Completed tab.

      for (final doc in canonicalCompletedSnap.docs) {
        try {
          final data = doc.data();

          final appStoryId = _resolveAppStoryId(
            firestoreDocId: doc.id,
            firestoreStoryIdentifier: data['storyId'] as String?,
            firestoreStoryTitle: data['storyTitle'] as String?,
            firestoreAppStoryId: data['appStoryId'] as String?,
          );

          final completedAt =
              _asDateTime(data['completedAt']) ?? DateTime.now();

          final existing = canonicalProgress[appStoryId];

// If the user has already reopened this story, keep the newer

// in-progress write instead of forcing it back to Completed.

          if (existing != null &&
              !existing.isCompleted &&
              existing.updatedAt.isAfter(completedAt)) {
            continue;
          }

// Completed state must win over any lingering in-progress doc.

          canonicalProgress[appStoryId] = StoryProgress(
            storyId: appStoryId,
            storyTitle: _resolveStoryTitle(
              appStoryId,
              fallback: data['storyTitle'] as String?,
            ),
            currentSegmentIndex: (_asInt(data['totalSegments']) ?? 1) - 1,
            totalSegments: _asInt(data['totalSegments']) ?? 0,
            isCompleted: true,
            correctAnswers: _asInt(data['correctAnswers']) ?? 0,
            totalQuestions: _asInt(data['totalQuestions']) ?? 0,
            starsEarned: _asInt(data['starsEarned']) ?? 0,
            skillCorrect: _asStringIntMap(data['skillCorrect']),
            skillTotal: _asStringIntMap(data['skillTotal']),
            startedAt: completedAt,
            completedAt: completedAt,
            updatedAt: completedAt,
            hintAttemptsUsed: _asInt(data['hintAttemptsUsed']) ?? 0,
          );
        } catch (e) {
          debugPrint(
              'Skipping malformed canonical completed doc ${doc.id}: $e');
        }
      }

      final canonicalFavorites = canonicalFavoritesSnap.docs
          .map((d) => _resolveAppStoryId(
                firestoreDocId: d.id,
                firestoreStoryIdentifier: d.data()['storyId'] as String?,
                firestoreStoryTitle: d.data()['storyTitle'] as String?,
                firestoreAppStoryId: d.data()['appStoryId'] as String?,
              ).trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final userModel = UserModel.fromJson({
        ...baseData,
        'id': uid,
        'completedCount': canonicalCompletedSnap.docs.length,
        'storyProgress':
            canonicalProgress.map((k, v) => MapEntry(k, v.toJson())),
        'favoriteStoryIds': canonicalFavorites,
      });

      // Ensure subcollections mirror the resolved model so console shows favorites and completed docs.
      await _mirrorCollectionsFromUserModel(
        userId: uid,
        storyProgress: canonicalProgress,
        favoriteIds: canonicalFavorites,
      );

      return userModel;
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
            'correctAnswers': entry.value.correctAnswers,
            'totalQuestions': entry.value.totalQuestions,
            'starsEarned': entry.value.starsEarned,
            'totalSegments': entry.value.totalSegments,
            'skillCorrect': entry.value.skillCorrect,
            'skillTotal': entry.value.skillTotal,
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
    String userId,
    StoryProgress progress, {
    bool clearCompletedVariants = false,
  }) async {
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
          'correctAnswers': progress.correctAnswers,
          'totalQuestions': progress.totalQuestions,
          'starsEarned': progress.starsEarned,
          'totalSegments': progress.totalSegments,
          'skillCorrect': progress.skillCorrect,
          'skillTotal': progress.skillTotal,
          'completedAt': progress.completedAt != null
              ? Timestamp.fromDate(progress.completedAt!)
              : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _deleteAllProgressDocsForStory(userId, progress.storyId);
      } else {
        await _upsertInProgressAndClearAllCompleted(userId, progress);
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
      await _syncUserCountsFromSubcollections(userId);
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
            'correctAnswers': entry.value.correctAnswers,
            'totalQuestions': entry.value.totalQuestions,
            'starsEarned': entry.value.starsEarned,
            'totalSegments': entry.value.totalSegments,
            'skillCorrect': entry.value.skillCorrect,
            'skillTotal': entry.value.skillTotal,
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
        debugPrint(
          'Ignoring legacy guest storiesCompleted counter ($guestStoriesCompleted); completedStories documents are canonical.',
        );
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

    debugPrint(
        'UserService: Saving progress uid=$userId storyId=${progress.storyId} key=$storyKey resolvedTitle=$resolvedTitle');

    await _progressCol(userId).doc(storyKey).set({
      'appStoryId': progress.storyId, // FIXED: Canonical app story ID

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

      'hintAttemptsUsed': progress.hintAttemptsUsed,

      'startedAt': Timestamp.fromDate(progress.startedAt),

      'completedAt': null,

      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _upsertInProgressAndClearAllCompleted(
    String userId,
    StoryProgress progress,
  ) async {
    final storyKey = _storyKeyForFirestore(
      appStoryId: progress.storyId,
      fallbackTitle: progress.storyTitle,
    );
    debugPrint(
        'UserService: Upserting story progress for user $userId, story key $storyKey, segment ${progress.currentSegmentIndex}');

    final resolvedTitle = _resolveStoryTitle(
      progress.storyId,
      fallback: progress.storyTitle,
    );

    final completedSnap = await _completedCol(userId).get();

    final writes = _firestore.batch();

    writes.set(
      _progressCol(userId).doc(storyKey),
      {
        'appStoryId': progress.storyId, // canonical app story id for fast resolution
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
        'hintAttemptsUsed': progress.hintAttemptsUsed,
        'startedAt': Timestamp.fromDate(progress.startedAt),
        'completedAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    for (final doc in completedSnap.docs) {
      final data = doc.data();

      final resolvedId = _resolveAppStoryId(
        firestoreDocId: doc.id,
        firestoreStoryIdentifier: data['storyId'] as String?,
        firestoreStoryTitle: data['storyTitle'] as String?,
        firestoreAppStoryId: data['appStoryId'] as String?,
      );

      if (resolvedId == progress.storyId ||
          doc.id == storyKey ||
          doc.id == progress.storyId) {
        writes.delete(doc.reference);
      }
    }

    await writes.commit();
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

  Future<void> _deleteAllProgressDocsForStory(
      String userId, String appStoryId) async {
    final progressSnap = await _progressCol(userId).get();

    final writes = _firestore.batch();

    var hasWrites = false;

    for (final doc in progressSnap.docs) {
      final data = doc.data();

      final resolvedId = _resolveAppStoryId(
        firestoreDocId: doc.id,
        firestoreStoryIdentifier: data['storyId'] as String?,
        firestoreStoryTitle: data['storyTitle'] as String?,
        firestoreAppStoryId: data['appStoryId'] as String?,
      );

      if (resolvedId == appStoryId) {
        writes.delete(doc.reference);

        hasWrites = true;
      }
    }

    if (hasWrites) {
      await writes.commit();
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
    String? firestoreAppStoryId,
  }) {
    final candidates = <String>[
      firestoreAppStoryId ?? '',
      firestoreStoryIdentifier ?? '',
      firestoreDocId,
      firestoreStoryTitle ?? '',
    ].map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    for (final candidate in candidates) {
      final byId = _storyService.getStoryById(candidate);

      if (byId != null) return byId.id;

      final byTitle = _storyService.getAllStories().where(
            (story) => _normalizeKey(story.title) == _normalizeKey(candidate),
          );

      if (byTitle.isNotEmpty) return byTitle.first.id;

      final normalizedCandidate = _normalizeKey(candidate);

      if (normalizedCandidate.isNotEmpty) {
        for (final story in _storyService.getAllStories()) {
          final normalizedStoryId = _normalizeKey(story.id);

          final normalizedStoryTitle = _normalizeKey(story.title);

          if (normalizedStoryId.contains(normalizedCandidate) ||
              normalizedCandidate.contains(normalizedStoryId) ||
              normalizedStoryTitle.contains(normalizedCandidate) ||
              normalizedCandidate.contains(normalizedStoryTitle)) {
            return story.id;
          }
        }
      }
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

  int? _asInt(dynamic value) {
    if (value is int) return value;

    if (value is num) return value.toInt();

    if (value is String) return int.tryParse(value);

    return null;
  }

  Map<String, int> _asStringIntMap(dynamic value) {
    if (value is! Map) return const <String, int>{};

    final result = <String, int>{};

    value.forEach((key, rawValue) {
      final parsed = _asInt(rawValue);

      if (parsed != null) {
        result[key.toString()] = parsed;
      }
    });

    return result;
  }

  String _normalizeKey(String value) {
    final lower = value.trim().toLowerCase();

    return lower.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  Map<String, dynamic>? _sanitizePreferencesMap(dynamic rawPreferences) {
    if (rawPreferences is! Map) return null;

    final source = Map<String, dynamic>.from(rawPreferences);

    final sanitized = <String, dynamic>{};

    if (source['language'] is String) {
      sanitized['language'] = source['language'];
    }

    if (source['voiceSpeed'] is num) {
      sanitized['voiceSpeed'] = (source['voiceSpeed'] as num).toDouble();
    }

    if (source['enableTTS'] is bool) {
      sanitized['enableTTS'] = source['enableTTS'];
    }

    if (source['enableAnimations'] is bool) {
      sanitized['enableAnimations'] = source['enableAnimations'];
    }

    if (mapEquals(source, sanitized)) return null;

    return sanitized;
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return const <String>[];

    return value
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Mirror favorites and completed progress into their canonical subcollections.
  Future<void> _mirrorCollectionsFromUserModel({
    required String userId,
    required Map<String, StoryProgress> storyProgress,
    required List<String> favoriteIds,
  }) async {
    final batch = _firestore.batch();
    var hasWrites = false;

    for (final id in favoriteIds.toSet()) {
      final storyKey = _storyKeyForFirestore(appStoryId: id);
      final resolvedTitle = _resolveStoryTitle(id);
      batch.set(
        _favoritesCol(userId).doc(storyKey),
        {
          'storyId': storyKey,
          'storyTitle': resolvedTitle ?? storyKey,
          'addedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      hasWrites = true;
    }

    for (final entry in storyProgress.entries) {
      final progress = entry.value;
      final storyKey = _storyKeyForFirestore(
        appStoryId: progress.storyId,
        fallbackTitle: progress.storyTitle,
      );
      final resolvedTitle =
          _resolveStoryTitle(progress.storyId, fallback: progress.storyTitle);

      if (progress.isCompleted) {
        batch.set(
          _completedCol(userId).doc(storyKey),
          {
            'storyId': storyKey,
            if (resolvedTitle != null) 'storyTitle': resolvedTitle,
            'score': progress.comprehensionScore,
            'correctAnswers': progress.correctAnswers,
            'totalQuestions': progress.totalQuestions,
            'starsEarned': progress.starsEarned,
            'totalSegments': progress.totalSegments,
            'skillCorrect': progress.skillCorrect,
            'skillTotal': progress.skillTotal,
            'completedAt': progress.completedAt != null
                ? Timestamp.fromDate(progress.completedAt!)
                : FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        batch.set(
          _progressCol(userId).doc(storyKey),
          {
            'appStoryId': progress.storyId,
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
            'hintAttemptsUsed': progress.hintAttemptsUsed,
            'startedAt': Timestamp.fromDate(progress.startedAt),
            'completedAt': null,
            'updatedAt': Timestamp.fromDate(progress.updatedAt),
          },
          SetOptions(merge: true),
        );
      }
      hasWrites = true;
    }

    if (hasWrites) {
      await batch.commit();
      await _syncUserCountsFromSubcollections(userId);
    }
  }

  Map<String, dynamic> _buildCanonicalUserDoc({
    required Map<String, dynamic> existingData,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    final normalizedPrefs =
        _sanitizePreferencesMap(existingData['preferences']) ??
            (existingData['preferences'] is Map
                ? Map<String, dynamic>.from(existingData['preferences'])
                : const UserPreferences().toJson());

    final createdAt = existingData['createdAt'];

    return <String, dynamic>{
      'displayName':
          displayName ?? _asNullableString(existingData['displayName']),
      'email': email ?? _asNullableString(existingData['email']),
      'photoUrl': photoUrl ?? _asNullableString(existingData['photoUrl']),
      'totalStars': _asInt(existingData['totalStars']) ?? 0,
      'progressCount': _asInt(existingData['progressCount']) ?? 0,
      'favoritesCount': _asInt(existingData['favoritesCount']) ?? 0,
      'completedCount': _asInt(existingData['completedCount']) ?? 0,
      'favoriteStoryIds': _asStringList(existingData['favoriteStoryIds']),
      'storyProgress': existingData['storyProgress'] is Map
          ? Map<String, dynamic>.from(existingData['storyProgress'])
          : <String, dynamic>{},
      'preferences': normalizedPrefs,
      'schemaVersion': 2,
      'isGuest':
          existingData['isGuest'] is bool ? existingData['isGuest'] : false,
      if (createdAt is Timestamp) 'createdAt': createdAt,
      if (createdAt is! Timestamp) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  String? _asNullableString(dynamic value) {
    if (value == null) return null;

    if (value is String) return value;

    final stringified = value.toString();

    return stringified.isEmpty ? null : stringified;
  }

  Map<String, dynamic> _legacyUserFieldFixes(Map<String, dynamic> data) {
    final fixes = <String, dynamic>{};

    final createdAt = data['createdAt'];

    if (createdAt != null && createdAt is! Timestamp) {
      fixes['createdAt'] = FieldValue.serverTimestamp();
    }

    final totalStars = _asInt(data['totalStars']);

    if (data['totalStars'] != null && data['totalStars'] is! int) {
      fixes['totalStars'] = totalStars ?? 0;
    }

    final progressCount = _asInt(data['progressCount']);

    if (data['progressCount'] != null && data['progressCount'] is! int) {
      fixes['progressCount'] = progressCount ?? 0;
    }

    final favoritesCount = _asInt(data['favoritesCount']);

    if (data['favoritesCount'] != null && data['favoritesCount'] is! int) {
      fixes['favoritesCount'] = favoritesCount ?? 0;
    }

    final completedCount = _asInt(data['completedCount']);

    if (data['completedCount'] != null && data['completedCount'] is! int) {
      fixes['completedCount'] = completedCount ?? 0;
    }

    if (data['isGuest'] != null && data['isGuest'] is! bool) {
      fixes['isGuest'] = false;
    }

    if (data['displayName'] != null &&
        data['displayName'] is! String &&
        data['displayName'].toString().isNotEmpty) {
      fixes['displayName'] = data['displayName'].toString();
    }

    if (data['email'] != null && data['email'] is! String) {
      fixes['email'] = data['email'].toString();
    }

    if (data['photoUrl'] != null && data['photoUrl'] is! String) {
      fixes['photoUrl'] = data['photoUrl'].toString();
    }

    return fixes;
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
                'correctAnswers': legacy.correctAnswers,
                'totalQuestions': legacy.totalQuestions,
                'starsEarned': legacy.starsEarned,
                'totalSegments': legacy.totalSegments,
                'skillCorrect': legacy.skillCorrect,
                'skillTotal': legacy.skillTotal,
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
        firestoreAppStoryId: data['appStoryId'] as String?,
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
              'correctAnswers': _asInt(data['correctAnswers']) ?? 0,
              'totalQuestions': _asInt(data['totalQuestions']) ?? 0,
              'starsEarned': _asInt(data['starsEarned']) ?? 0,
              'totalSegments': _asInt(data['totalSegments']) ?? 0,
              'skillCorrect': _asStringIntMap(data['skillCorrect']),
              'skillTotal': _asStringIntMap(data['skillTotal']),
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
        firestoreAppStoryId: data['appStoryId'] as String?,
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
        firestoreAppStoryId: data['appStoryId'] as String?,
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

  /// Clean up stories with currentSegmentIndex = 0 (never actually read), but keep recent "soft starts"
  /// FIX: Soften filter - keep if updatedAt within 24h (user opened but not read yet)
  Future<void> cleanupUnstartedStories(String userId) async {
    try {
      final progressSnap = await _progressCol(userId).get();
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
      final writes = _firestore.batch();
      var hasWrites = false;
      var keptCount = 0;
      var deletedCount = 0;
      debugPrint(
          'UserService.cleanup($userId): Starting cleanup of ${progressSnap.docs.length} docs...');

      for (final doc in progressSnap.docs) {
        final data = doc.data();
        final currentSegmentIndex = _asInt(data['currentSegmentIndex']) ?? 0;
        final updatedAt = _asDateTime(data['updatedAt']);

        if (currentSegmentIndex == 0 &&
            updatedAt != null &&
            updatedAt.isBefore(cutoffTime)) {
          debugPrint(
              'UserService.cleanup: Deleting old unstarted doc ${doc.id} (updated: $updatedAt)');
          writes.delete(doc.reference);
          hasWrites = true;
          deletedCount++;
        } else if (currentSegmentIndex == 0) {
          debugPrint(
              'UserService.cleanup: Keeping recent soft-start ${doc.id} (updated: $updatedAt)');
          keptCount++;
        }
      }

      if (hasWrites) {
        await writes.commit();
        await _syncUserCountsFromSubcollections(userId);
      }
      debugPrint(
          'UserService.cleanup($userId): Deleted $deletedCount unstarted, kept $keptCount recent soft-starts.');
    } catch (e) {
      debugPrint('Error cleaning up unstarted stories: $e');
    }
  }

  // --- CHILD PROFILES ---
  Future<List<ChildProfileModel>> getChildProfiles(String parentUid) async {    
    final snap = await _firestore.collection('users').doc(parentUid).collection('profiles').get();
    return snap.docs.map((doc) => ChildProfileModel.fromJson(doc.data(), doc.id)).toList();
  }

  Future<ChildProfileModel> createChildProfile(String parentUid, String displayName, String avatarAsset) async {
    final docRef = _firestore.collection('users').doc(parentUid).collection('profiles').doc();
    final profile = ChildProfileModel(
      id: docRef.id,
      parentId: parentUid,
      displayName: displayName,
      avatarAsset: avatarAsset,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(profile.toJson());
    return profile;
  }
}
